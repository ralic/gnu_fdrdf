### stat.pm --- FDRDF: stat(2) module  -*- Perl -*-

### Ivan Shmakov, 2010
## This code is in the public domain.

package fdrdf::module::stat;

use strict;
use warnings;

use RDF::Redland;

use fdrdf::proto::io;

BEGIN {
    use Exporter ();
    our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

    # set the version for version checking
    $VERSION = 0.1;

    @ISA = qw (Exporter fdrdf::proto::io);
    @EXPORT = qw ();
    %EXPORT_TAGS = ();
    @EXPORT_OK = qw ();

    ## URI's and prefixes
    our $module_uri_s
        = "uuid:21624fe2-b54f-11df-b9c0-4040a5e6bfa3";
    our $conf_prefix
        = $module_uri_s . "#cf.";
    our $desc_prefix
        = "uuid:2e22aa82-b550-11df-9d5c-4040a5e6bfa3#stat.";
    our $num_prefix
        = $desc_prefix . "n.";
    our $sym_prefix
        = $desc_prefix . "s.";

    our (@keys_list);
    @keys_list
        = qw(dev ino mode nlink uid gid _rdev size
             atime mtime ctime blksize blocks);
    # atime_usec mtime_usec ctime_usec
    our ($xs_prefix, @xs_types_list);
    $xs_prefix = "http://www.w3.org/2001/XMLSchema#";
    @xs_types_list = qw(integer);
}

## NB: not an OO method
sub uri_node {
    ## .
    return new RDF::Redland::URINode (@_);
}

sub process_stat {
    my ($self, $model, $subject, @stat) = @_;
    our (@keys_list);

    my $s = $subject;
    my @r = @stat;
    my $num
        = $self->{"uri.type.xs.integer"};
    for (my $i = 0; $i <= $#keys_list; $i++) {
        my $key = $keys_list[$i];
        next
            if ($key =~ /^_/);
        {
            my $p
                = $self->{"node.pred.numeric"}->{$key};
            my $o
                = new RDF::Redland::LiteralNode ("" . $r[$i], $num);
            $model->add_statement ($s, $p, $o);
        }
    }
}

sub process_io {
    my ($self, $model, $subject, $io) = @_;

    ## FIXME: cannot do lstat () here
    my @r = stat ($io);
    $self->process_stat ($model, $subject, @r);
}

sub new {
    my ($class, $callback) = @_;

    our ($module_uri_s, $conf_prefix);
    our ($desc_prefix);
    our ($num_prefix,   $sym_prefix);
    my $self = {
        "module"    => uri_node ($module_uri_s),
        "conf_pfx"  => $conf_prefix,
        "desc_pfx"  => $desc_prefix,
        "num_pfx"   =>  $num_prefix,
        "sym_pfx"   =>  $sym_prefix
    };
    our (@keys_list);
    our ($xs_prefix, @xs_types_list);
    foreach my $type (@xs_types_list) {
        $self->{"uri.type.xs." . $type}
            = new RDF::Redland::URI ($xs_prefix . $type);
    }
    foreach my $key (@keys_list) {
        next
            if ($key =~ /^_/);
        my $uri_s = $num_prefix . $key;
        $self->{"node.pred.numeric"}->{$key}
            = new RDF::Redland::URINode ($uri_s);
    }

    bless ($self, $class);

    ## .
    $self;
}

1;

## Local variables:
## indent-tabs-mode: nil
## fill-column: 72
## End:
### stat.pm ends here
