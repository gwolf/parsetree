require 'test/unit'
require 'parse_tree'
require 'parse_tree_extensions'
require 'tmpdir'

$: << "../../ruby2ruby/dev/lib" # unoffical dependency - user responsibility
require 'ruby2ruby'

class R2RTestCase < Test::Unit::TestCase
  def test_proc_to_ruby
    util_setup_inline
    block = proc { puts "something" }
    assert_equal 'proc { puts("something") }', block.to_ruby
  end

  def test_proc_to_sexp
    util_setup_inline
    p = proc { 1 + 1 }
    s = s(:iter,
          s(:call, nil, :proc, s(:arglist)),
          nil,
          s(:call, s(:lit, 1), :+, s(:arglist, s(:lit, 1))))
    assert_equal s, p.to_sexp
  end

  def test_proc_to_sexp_args
    util_setup_inline
    p = proc {|a, b, c|}
    s = s(:iter,
          s(:call, nil, :proc, s(:arglist)),
          s(:masgn, s(:array, s(:lasgn, :a), s(:lasgn, :b), s(:lasgn, :c))))

    assert_equal s, p.to_sexp
  end

  def test_parse_tree-for_proc # TODO: move?
    p = proc {|a, b, c|}
    s = s(:iter,
          s(:call, nil, :proc, s(:arglist)),
          s(:masgn, s(:array, s(:lasgn, :a), s(:lasgn, :b), s(:lasgn, :c))))

    pt = ParseTree.new(false)
    u = Unifier.new
    sexp = pt.parse_tree_for_proc p

    sexp = u.process(sexp)

    assert_equal s, sexp
  end

  def test_unbound_method_to_ruby
    util_setup_inline
    r = "proc { ||\n  util_setup_inline\n  p = proc { (1 + 1) }\n  s = s(:iter, s(:call, nil, :proc, s(:arglist)), nil, s(:call, s(:lit, 1), :+, s(:arglist, s(:lit, 1))))\n  assert_equal(s, p.to_sexp)\n}"
    m = self.class.instance_method(:test_proc_to_sexp)

    assert_equal r, m.to_ruby
  end

  def util_setup_inline
    @rootdir = File.join(Dir.tmpdir, "test_ruby_to_ruby.#{$$}")
    Dir.mkdir @rootdir, 0700 unless test ?d, @rootdir
    ENV['INLINEDIR'] = @rootdir
  end
end
