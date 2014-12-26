sudo yum install cpan -y
perl -MCPAN -e '$ENV{PERL_MM_USE_DEFAULT} = 3; install Net::SSH::Perl'
$ENV{PERL_MM_USE_DEFAULT} = 3
