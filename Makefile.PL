use 5.014002;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Mail::Trash',
    VERSION_FROM      => 'lib/Mail/Trash/Inbox.pm', # finds $VERSION
    PREREQ_PM         => {
		'Carp' => 0,
		'LWP::UserAgent' => 0,
		'Common::Util::XML' => 0,
		'XML::LibXML' => 0
	}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Mail/Trash/Inbox.pm', # retrieve abstract from module
       AUTHOR         => '8ware <8wared@googlemail.com>') : ()),
);
