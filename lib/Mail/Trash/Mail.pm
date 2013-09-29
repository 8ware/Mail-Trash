package Mail::Trash::Mail;

use 5.014002;
use strict;
use warnings;

=head1 NAME

Mail::Trash::Mail - simple mail data structure

=head1 SYNOPSIS

  use Mail::Trash::Mail;

  # create mail with its URL
  my $mail = Mail::Trash::Mail->new($url);

  # fetch information and content
  $mail->fetch();

  # print information
  say "sender:  ", $mail->sender();
  say "subject: ", $mail->subject();
  say "received on ", $mail->date(), " at ", $mail->time();

  # print formatted content
  my $formatter = HTML::FormatText::WithLinks->new();
  say $formatter->parse($mail->content());

  # delete mail after reading
  $mail->delete();

=head1 DESCRIPTION

This module serves as simple data structure for a mail while providing
some functional features as fetching the mail's information and content
and deleting it.

=head2 EXPORT

None by default. All subroutines are accessed via object oriented approach.

=cut

our $VERSION = '0.01';


use Common::Util::XML;
use Mail::Trash::Utils;


=head2 METHODS

=over 4

=item C<new>

Creates a new mail object with the given URL.

=cut

sub new($$) {
	my $class = shift;
	my $url = shift;

	my $self = {
		url => $url,
	};

	return bless $self, $class;
}

=item C<fetch>

Fetches the mail's information and content from C<trash-mail.com>.

=cut

sub fetch($) {
	my $self = shift;

	my $html = fetch_html($self->url(), "fetching mail failed", 1);

	my @tds = $html->getElementsByAttribute('td', 'class',
			qr/^mail_(right|content)$/);
	die unless @tds == 5;

	my $sender = $tds[0]->textContent() =~ s/^\W//r;
	my $subject = $tds[1]->textContent() =~ s/^\W//r;
	my $content = $tds[4]->serialize(1);

	$self->sender($sender);
	$self->subject($subject);
	$self->content($content);

	return $self;
}

=item C<url>

Returns the url of the mail.

=cut

sub url($) {
	my $self = shift;

	return $self->{url};
}

=item C<sender>

Returns the originator of the mail.

=cut

sub sender($;$) {
	my $self = shift;
	my $sender = shift;

	$self->{sender} = $sender if $sender;

	return $self->{sender};
}

=item C<subject>

Returns the mail's subject.

=cut

sub subject($;$) {
	my $self = shift;
	my $subject = shift;

	$self->{subject} = $subject if $subject;

	return $self->{subject};
}

=item C<date>

Returns the date the mail was received (on C<trash-mail.com>).

=cut

sub date($;$) {
	my $self = shift;
	my $date = shift;

	$self->{date} = $date if $date;

	return $self->{date};
}

=item C<time>

Returns the time the mail was received (on C<trash-mail.com>).

=cut

sub time($;$) {
	my $self = shift;
	my $time = shift;

	$self->{time} = $time if $time;

	return $self->{time};
}

=item C<content>

Delivers the content of the mail.

=cut

sub content($;$) {
	my $self = shift;
	my $content = shift;

	$self->{content} = $content if $content;

	return $self->{content};
}

=item C<delete>

Deletes the mail from C<trash-mail.com>.

=cut

sub delete($) {
	my $self = shift;

	my $url = $self->url();
	my ($mid, $tid) = $url =~ /&mid=(\d+)&tid=(\d+)/;
	my $delurl = $url =~ s/(?<=index\.html\?).+/del=${mid}x${tid}/r;

	send_request($delurl, "deletion failed");
}

=back

=cut


1;
__END__

=head1 SEE ALSO

=over 4

=item Mail::Trash::Inbox

fetches mails from C<trash-mail.com>

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

