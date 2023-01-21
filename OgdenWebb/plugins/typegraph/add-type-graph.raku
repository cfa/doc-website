use v6.d;
use Perl6::TypeGraph;
use Perl6::TypeGraph::Viz;

sub ($pp, %options) {
    unless 'typegraphs'.IO ~~ :e & :d and 'type-graph.txt'.IO.modified le 'typegraphs'.IO.modified {
        mkdir 'typegraphs' unless 'typegraphs'.IO ~~ :e & :d;
        my $viz = Perl6::TypeGraph::Viz.new;
        my $tg = Perl6::TypeGraph.new-from-file('type-graph.txt');
        $viz.write-type-graph-images(path => "typegraphs",
            :force,
            type-graph => $tg);
        .unlink for 'typegraphs'.IO.dir( test => *.ends-with('.dot') );
        for 'typegraphs'.IO.dir {
            .rename: .Str.subst(/ 'type-graph-' /, '').subst(/ \:\: /, '', :g)
        }
    }
    my %ns;
    my @files = 'typegraphs'.IO.dir(test => *.ends-with('.svg'))>>.relative('typegraphs')>>.IO>>.extension('');
    for @files {
        %ns<typegraphs>{ $_ } = "typegraphs/$_\.svg".IO.slurp.subst( / ^ .+? <?before '<svg'> /, '')
    }
    if 'pod' ~~ $pp.plugin-datakeys {
        my %ns-ex := $pp.get-data('pod');
        %ns-ex<typegraphs> = %ns<typegraphs>;
    }
    else {
        $pp.add-data('pod', %ns)
    }
    @files.map( { ["assets/typegraphs/$_\.svg", 'myself', "typegraphs/$_\.svg"] } );
}