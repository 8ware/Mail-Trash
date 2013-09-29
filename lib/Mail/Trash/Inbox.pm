package Mail::Trash::Inbox;

use 5.014002;
use strict;
use warnings;

=head1 NAME

Mail::Trash::Inbox - interface to the inbox of C<trash-mail.com>

=head1 SYNOPSIS

  use Mail::Trash::Inbox;

  my $inbox = Mail::Trash::Inbox->new('test');
  my @mails = $inbox->fetch_mails();

  for my $mail (@mails) {
      $mail->fetch();
	  # do some stuff with the mail...
  }

=head1 DESCRIPTION

This module provides access to the web inbox of C<trash-mail.com>. It
fetches the mails for a certain user/name and delivers them with some
preset information. In fact this will be the date and time of reception
and the sender and subject of the mail. The sender and subject MAY NOT
fully given because they are abbreviated on the web inbox. To get the
full sender and subject the mail must be fetched firstly as shown above.

=head2 EXPORT

None by default. All subroutines are accessed via object oriented approach.

=cut

our $VERSION = '0.01';


use Common::Util::XML;
use Mail::Trash::Mail;
use Mail::Trash::Utils;


my $BASE_URL = "http://trash-mail.com";


=head2 METHODS

=over 4

=item C<new>

Creates a new ibox object which will fetch the mails for the given user/name.

=cut

sub new($$) {
	my $class = shift;
	my $name = shift;

	my $self = {
		inbox => "$BASE_URL/index.php?ln=p&mail=$name"
	};

	return bless $self, $class;
}

=item C<fetch_mails>

Fetches the mails in the web inbox specified through the user/name.

=cut

sub fetch_mails($) {
	my $self = shift;

	my $html = fetch_html($self->{inbox}, "fetching inbox failed", 1);

	my @mails;
	for my $tr ($html->getElementsByTagName('tr')) {
		my @tds = $tr->getElementsByAttribute('td', 'class', qr/^post_data$/);
		next unless @tds;

		my $a = $tds[0]->getElementByTagName('a');
		my $url = "$BASE_URL/" . $a->getAttribute('href');
		my $sender = $tds[0]->textContent() =~ s/^\W//r;
		my $subject = $tds[1]->textContent() =~ s/^\W//r;
		my $datetime = $tds[2]->textContent() =~ s/^\W//r;
		my ($date, $time)
				= $datetime =~ /(\d{2}\.\d{2}\.\d{2}).um.(\d{2}:\d{2}:\d{2})/;

		my $mail = Mail::Trash::Mail->new($url);
		$mail->sender($sender);
		$mail->subject($subject);
		$mail->date($date);
		$mail->time($time);
		
		push @mails, $mail;
	}

	return @mails;
}

=back

=cut


1;
__END__

=head1 SEE ALSO

=over 4

=item Mail::Trash::Mail

the data structure which contains the mail's information and content

=item L<onsale|https://github.com/8ware/onsale>

the initiating project

=item L<trash-mail.com|http://trash-mail.com>

=back

=head1 AUTHOR

8ware, E<lt>8wared@googlemail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by 8ware

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.

=cut

