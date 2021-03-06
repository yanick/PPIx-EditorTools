use MooseX::Declare;

role Moofirst {
	requires '_build_overdraft';
	use version; our $VERSION = version->new('1.0.1');

	has 'balance' => (
		isa     => 'Num',
		is      => 'rw',
		default => 0
	);

	has 'overdraft' => (
		isa        => 'Bool',
		is         => 'rw',
		lazy_build => 1,
		init_arg   => undef,
	);
}

class Mooclass {

	has 'name' => ( isa => 'Str', is => 'rw', );

	has qw(account) => ( is => 'rw', );

	method _build_overdraft {
		return;
	}
}
