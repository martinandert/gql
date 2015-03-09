require 'cases/helper'

class CallerTarget
  attr_reader :value

  def initialize
    @value = []
  end

  def foo(times = 1)
    @value << ('foo' * times)
    self
  end

  alias :foo_with_returns :foo

  def <<(value)
    @value << value
    self
  end
end

class CallClassWithoutResultClass < GQL::Call
  def execute(times = 1)
    target << ('baz' * times)
  end
end

class CallClassWithExplicitResultClass < GQL::Call
  def execute(times = 1)
    target << ('bam' * times)

    { result: target.value }
  end

  class Result < GQL::Node
    field :result, -> { target[:result] }, type: GQL::Raw
  end

  returns Result
end

class CallClassWithImplicitResultClass < GQL::Call
  def execute(times = 1)
    target << ('boo' * times)

    { result: target.value }
  end

  returns do
    field :result, type: GQL::Raw
  end
end

class FooBarResultClass < GQL::Node
  field :foobar, -> { target }, type: GQL::Raw
  field :foobar_value, -> { target.value }, type: GQL::Raw
end

class NodeWithCalls < GQL::Node
  object :me, -> { target }, node_class: NodeWithCalls
  field :value, type: GQL::Raw

  call :foo
  call :foo_with_returns, returns: FooBarResultClass

  call :bar,              -> (times = 1) { target << ('bar' * times) }
  call :bar_with_returns, -> (times = 1) { target << ('bar' * times) }, returns: FooBarResultClass

  call :baz,              CallClassWithoutResultClass
  call :baz_with_returns, CallClassWithoutResultClass, returns: FooBarResultClass

  call :bam,              CallClassWithExplicitResultClass
  call :bam_with_returns, CallClassWithExplicitResultClass, returns: FooBarResultClass

  call :boo,              CallClassWithImplicitResultClass
  call :boo_with_returns, CallClassWithImplicitResultClass, returns: FooBarResultClass
end

class Inherited < NodeWithCalls
  call :bingo, -> { 'BINGO!' }, returns: GQL::Raw
end

class CallTest < GQL::TestCase
  setup do
    @old_root, GQL.root_node_class = GQL.root_node_class, NodeWithCalls
    @old_proc, GQL.root_target_proc = GQL.root_target_proc, -> _ { CallerTarget.new }
  end

  teardown do
    GQL.root_target_proc = @old_proc
    GQL.root_node_class = @old_root
  end

  test "without proc and result class and returns" do
    assert_equal({ value: ['foo'] }, GQL.execute('foo { value }'))
    assert_equal({ value: ['foo'] }, GQL.execute('foo() { value }'))
    assert_equal({ value: ['foofoo'] }, GQL.execute('foo(2) { value }'))

    assert_equal({ me: { value: ['foo'] } }, GQL.execute('{ me.foo { value } }'))
    assert_equal({ me: { value: ['foo'] } }, GQL.execute('{ me.foo() { value } }'))
    assert_equal({ me: { value: ['foofoo'] } }, GQL.execute('{ me.foo(2) { value } }'))

    assert_equal({ me: { value: ['foo'] } }, GQL.execute('foo { me { value } }'))
    assert_equal({ me: { value: ['foo'] } }, GQL.execute('foo() { me { value } }'))
    assert_equal({ me: { value: ['foofoo'] } }, GQL.execute('foo(2) { me { value } }'))

    assert_equal({ me: { me: { value: ['foo'] } } }, GQL.execute('{ me.foo { me { value } } }'))
    assert_equal({ me: { me: { value: ['foo'] } } }, GQL.execute('{ me.foo() { me { value } } }'))
    assert_equal({ me: { me: { value: ['foofoo'] } } }, GQL.execute('{ me.foo(2) { me { value } } }'))
  end

  test "without proc and result class and with returns" do
    assert_equal({ foobar_value: ['foofoo'] }, GQL.execute('foo_with_returns(2) { foobar_value }'))
    assert_equal({ me: { foobar_value: ['foofoo'] } }, GQL.execute('{ me.foo_with_returns(2) { foobar_value } }'))
  end

  test "with proc and without result class and returns" do
    assert_equal({ value: ['bar'] }, GQL.execute('bar { value }'))
    assert_equal({ value: ['bar'] }, GQL.execute('bar() { value }'))
    assert_equal({ value: ['barbar'] }, GQL.execute('bar(2) { value }'))

    assert_equal({ me: { value: ['bar'] } }, GQL.execute('{ me.bar { value } }'))
    assert_equal({ me: { value: ['bar'] } }, GQL.execute('{ me.bar() { value } }'))
    assert_equal({ me: { value: ['barbar'] } }, GQL.execute('{ me.bar(2) { value } }'))

    assert_equal({ me: { value: ['bar'] } }, GQL.execute('bar { me { value } }'))
    assert_equal({ me: { value: ['bar'] } }, GQL.execute('bar() { me { value } }'))
    assert_equal({ me: { value: ['barbar'] } }, GQL.execute('bar(2) { me { value } }'))

    assert_equal({ me: { me: { value: ['bar'] } } }, GQL.execute('{ me.bar { me { value } } }'))
    assert_equal({ me: { me: { value: ['bar'] } } }, GQL.execute('{ me.bar() { me { value } } }'))
    assert_equal({ me: { me: { value: ['barbar'] } } }, GQL.execute('{ me.bar(2) { me { value } } }'))
  end

  test "with proc and without result class and with returns" do
    assert_equal({ foobar_value: ['barbar'] }, GQL.execute('bar_with_returns(2) { foobar_value }'))
    assert_equal({ me: { foobar_value: ['barbar'] } }, GQL.execute('{ me.bar_with_returns(2) { foobar_value } }'))
  end

  test "with call class and without returns" do
    assert_equal({ value: ['baz'] }, GQL.execute('baz { value }'))
    assert_equal({ value: ['baz'] }, GQL.execute('baz() { value }'))
    assert_equal({ value: ['bazbaz'] }, GQL.execute('baz(2) { value }'))

    assert_equal({ me: { value: ['baz'] } }, GQL.execute('{ me.baz { value } }'))
    assert_equal({ me: { value: ['baz'] } }, GQL.execute('{ me.baz() { value } }'))
    assert_equal({ me: { value: ['bazbaz'] } }, GQL.execute('{ me.baz(2) { value } }'))

    assert_equal({ me: { value: ['baz'] } }, GQL.execute('baz { me { value } }'))
    assert_equal({ me: { value: ['baz'] } }, GQL.execute('baz() { me { value } }'))
    assert_equal({ me: { value: ['bazbaz'] } }, GQL.execute('baz(2) { me { value } }'))

    assert_equal({ me: { me: { value: ['baz'] } } }, GQL.execute('{ me.baz { me { value } } }'))
    assert_equal({ me: { me: { value: ['baz'] } } }, GQL.execute('{ me.baz() { me { value } } }'))
    assert_equal({ me: { me: { value: ['bazbaz'] } } }, GQL.execute('{ me.baz(2) { me { value } } }'))
  end

  test "with call class and returns" do
    assert_equal({ foobar_value: ['bazbaz'] }, GQL.execute('baz_with_returns(2) { foobar_value }'))
    assert_equal({ me: { foobar_value: ['bazbaz'] } }, GQL.execute('{ me.baz_with_returns(2) { foobar_value } }'))
  end

  test "with call class (explicit result class) and without returns" do
    assert_equal({ result: ['bam'] }, GQL.execute('bam { result }'))
    assert_equal({ result: ['bam'] }, GQL.execute('bam() { result }'))
    assert_equal({ result: ['bambam'] }, GQL.execute('bam(2) { result }'))

    assert_equal({ me: { result: ['bam'] } }, GQL.execute('{ me.bam { result } }'))
    assert_equal({ me: { result: ['bam'] } }, GQL.execute('{ me.bam() { result } }'))
    assert_equal({ me: { result: ['bambam'] } }, GQL.execute('{ me.bam(2) { result } }'))
  end

  test "with call class (explicit result class) and returns" do
    assert_equal({ foobar: { result: ['bambam'] } }, GQL.execute('bam_with_returns(2) { foobar }'))
    assert_equal({ me: { foobar: { result: ['bambam'] } } }, GQL.execute('{ me.bam_with_returns(2) { foobar } }'))
  end

  test "with call class (implicit result class) and without returns" do
    assert_equal({ result: ['boo'] }, GQL.execute('boo { result }'))
    assert_equal({ result: ['boo'] }, GQL.execute('boo() { result }'))
    assert_equal({ result: ['booboo'] }, GQL.execute('boo(2) { result }'))

    assert_equal({ me: { result: ['boo'] } }, GQL.execute('{ me.boo { result } }'))
    assert_equal({ me: { result: ['boo'] } }, GQL.execute('{ me.boo() { result } }'))
    assert_equal({ me: { result: ['booboo'] } }, GQL.execute('{ me.boo(2) { result } }'))
  end

  test "with call class (implicit result class) and returns" do
    assert_equal({ foobar: { result: ['booboo'] } }, GQL.execute('boo_with_returns(2) { foobar }'))
    assert_equal({ me: { foobar: { result: ['booboo'] } } }, GQL.execute('{ me.boo_with_returns(2) { foobar } }'))
  end

  test "constants" do
    expected = {
      foo:              NodeWithCalls::FooCall,
      foo_with_returns: NodeWithCalls::FooWithReturnsCall,
      bar:              NodeWithCalls::BarCall,
      bar_with_returns: NodeWithCalls::BarWithReturnsCall,
      baz:              NodeWithCalls::BazCall,
      baz_with_returns: NodeWithCalls::BazWithReturnsCall,
      bam:              NodeWithCalls::BamCall,
      bam_with_returns: NodeWithCalls::BamWithReturnsCall,
      boo:              NodeWithCalls::BooCall,
      boo_with_returns: NodeWithCalls::BooWithReturnsCall
    }

    assert_equal expected, NodeWithCalls.calls
  end

  test "superclasses" do
    assert_equal GQL::Call,                         NodeWithCalls.calls[:foo].superclass
    assert_equal GQL::Call,                         NodeWithCalls.calls[:foo_with_returns].superclass
    assert_equal GQL::Call,                         NodeWithCalls.calls[:bar].superclass
    assert_equal GQL::Call,                         NodeWithCalls.calls[:bar_with_returns].superclass
    assert_equal CallClassWithoutResultClass,       NodeWithCalls.calls[:baz].superclass
    assert_equal CallClassWithoutResultClass,       NodeWithCalls.calls[:baz_with_returns].superclass
    assert_equal CallClassWithExplicitResultClass,  NodeWithCalls.calls[:bam].superclass
    assert_equal CallClassWithExplicitResultClass,  NodeWithCalls.calls[:bam_with_returns].superclass
    assert_equal CallClassWithImplicitResultClass,  NodeWithCalls.calls[:boo].superclass
    assert_equal CallClassWithImplicitResultClass,  NodeWithCalls.calls[:boo_with_returns].superclass
  end

  test "ids" do
    assert_equal 'foo',                NodeWithCalls.calls[:foo].id
    assert_equal 'foo_with_returns',   NodeWithCalls.calls[:foo_with_returns].id
    assert_equal 'bar',                NodeWithCalls.calls[:bar].id
    assert_equal 'bar_with_returns',   NodeWithCalls.calls[:bar_with_returns].id
    assert_equal 'baz',                NodeWithCalls.calls[:baz].id
    assert_equal 'baz_with_returns',   NodeWithCalls.calls[:baz_with_returns].id
    assert_equal 'bam',                NodeWithCalls.calls[:bam].id
    assert_equal 'bam_with_returns',   NodeWithCalls.calls[:bam_with_returns].id
    assert_equal 'boo',                NodeWithCalls.calls[:boo].id
    assert_equal 'boo_with_returns',   NodeWithCalls.calls[:boo_with_returns].id
  end

  test "inheritance" do
    assert_equal 10, NodeWithCalls.calls.size
    assert_equal 11, Inherited.calls.size

    assert_equal NodeWithCalls.calls.keys + [:bingo], Inherited.calls.keys
  end

  test "chaining" do
    expected = { value: ['foo', 'bar', 'bazbaz', 'foo', 'barbar', 'baz', 'foofoo', 'bar', 'baz'] }
    actual = GQL.execute('foo.bar().baz(2).foo().bar(2).baz.foo(2).bar.baz() { value }')

    assert_equal expected, actual
  end
end
