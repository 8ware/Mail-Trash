package Mail::Trash::Utils;

use 5.014002;
use strict;
use warnings;

=head1 NAME

Mail::Trash::Utils - module which provides utility subroutines

=head1 SYNOPSIS

  use Mail::Trash::Utils;

  $response = send_request($url);
  $response = send_request($url, $error_msg);
  $response = send_request($url, $error_msg, $die_on_failure);

  $html = fetch_html($url);
  $html = fetch_html($url, $error_msg);
  $html = fetch_html($url, $error_msg, $die_on_failure);

=head1 DESCRIPTION

This module provides just some utility subroutines which were used by the
C<Mail::Trash::Inbox> and C<Mail::Trash::Mail> modules.

=head2 EXPORT

Exports C<send_request> and C<fetch_html> by default.

=cut

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT = qw( send_request fetch_html );

our $VERSION = '0.01';


use Carp;
use LWP::UserAgent;
use XML::LibXML;


my $AGENT = LWP::UserAgent->new();


=head2 SUBROUTINES

=over 4

=item C<send_request>

Sends a HTTP request and returns the received content unless the request
failed (in this case C<undef> is returned). The first argument is the
mandatory URL. Argument two is an optional error message and argument three
a flag which indicates whether to die on failure or just warning. The error
message defaults to C<fetching $url failed> while the flag is unset.

=cut

sub send_request($;$$) {
	my $url = shift;
	my $error_msg = shift || "fetching $url failed";
	my $die_on_failure = shift || 0;
	
	my $response = $AGENT->get($url);
	unless ($response->is_success()) {
		my $msg = "$error_msg: ", $response->status_line();
		$die_on_failure ? croak($msg) : carp($msg);
		return undef;
	}

	return $response->decoded_content();
}

=item C<fetch_html>

This subroutine excepts the same arguments as C<send_request> but will
parse the fetched content with the C<XML::LibXML> module. Returns the
fetched HTML content as XML object or undef if the request was not
successfully send and the fatal flag was unset.

=cut

sub fetch_html($;$$) {
	my $content = send_request(shift, shift, shift) or return undef;

	my $html = XML::LibXML->load_html(
			string => $content,
			load_ext_dtd => 0,
			expand_entities => 1,
			recover => 2,
			suppress_warnings => 1,
			suppress_errors => 1
	);

	return $html;
}

=back

=cut


1;
__END__

=head1 SEE ALSO

=over 4

=item C<XML::LibXML>

the module which is used to parse HTML

=back

=head1 AUTHOR

8ware, E<lt>8wared@googlemail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by 8ware

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.

=cut

