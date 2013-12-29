configure_require 'ExtUtils::MakeMaker', '6.66';
build_require 'ExtUtils::MakeMaker', '6.66';

requires 'version', '0.77';
requires 'LWP', '0';
requires 'LWP::Protocol::https', '0';
requires 'Mozilla::CA', '0';
requires 'Try::Lite', '0';
requires 'File::Copy::Recursive', '0';

requires 'autodie', '0';
requires 'parent', '0';

test_requires 'Test::More', '0.98';
test_requires 'Test::Output', '0';
test_requires 'Test::Exception', '0';
