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

  class Result < GQL::Field
    field :result, -> { target[:result] }, type: GQL::Scalar
  end

  returns Result
end

class CallClassWithImplicitResultClass < GQL::Call
  def execute(times = 1)
    target << ('boo' * times)

    { result: target.value }
  end

  returns do
    field :result, type: GQL::Scalar
  end
end

class CallClassAsString < GQL::Call
  def execute(times = 1)
    target << ('boo' * times)

    { result: target.value }
  end

  returns do
    field :result, type: GQL::Scalar
  end
end

class CallClassWithoutExecuteMethod < GQL::Call
end

class FooBarResultClass < GQL::Field
  field :foobar, -> { target }, type: GQL::Scalar
  field :foobar_value, -> { target.value }, type: GQL::Scalar
end

class AResultClass < Struct.new(:a)
end

class BResultClass < Struct.new(:b)
end

class AResultClassField < GQL::Field
  string :a
end

class BResultClassField < GQL::Field
  string :b
end

class CallClassWithMappingResultClass < GQL::Call
  def execute(x)
    x == 1 ? AResultClass.new('a') : BResultClass.new('b')
  end

  returns AResultClass => 'AResultClassField', BResultClass => BResultClassField
end

class FieldWithCalls < GQL::Field
  object :me, -> { target }, object_class: FieldWithCalls
  field :value, type: GQL::Scalar

  call :foo
  call :foo_with_returns, returns: FooBarResultClass

  call :bar,              -> (times = 1) { target << ('bar' * times) }
  call :bar_with_returns, -> (times = 1) { target << ('bar' * times) }, returns: FooBarResultClass

  call :baz,              CallClassWithoutResultClass
  call :baz_with_returns, CallClassWithoutResultClass, returns: FooBarResultClass

  call :bam,              CallClassWithExplicitResultClass
  call :bam_with_returns, CallClassWithExplicitResultClass, returns: 'FooBarResultClass'

  call :boo,              CallClassWithImplicitResultClass
  call :boo_with_returns, CallClassWithImplicitResultClass, returns: FooBarResultClass

  call :pow, returns: GQL::Number do |a, b|
    a ** b
  end

  call :no_execute_method, CallClassWithoutExecuteMethod

  call :with_connection_result, returns: [GQL::String]

  call :mapped_object_as_returns, returns: { AResultClass => AResultClassField, BResultClass => 'BResultClassField' } do |x|
    x == 1 ? AResultClass.new('a') : BResultClass.new('b')
  end

  call :call_class_returning_mapping, CallClassWithMappingResultClass

  call :call_class_as_string, 'CallClassAsString'
end

class Inherited < FieldWithCalls
  call :bingo, -> { 'BINGO!' }, returns: GQL::Scalar
end

class CallTest < ActiveSupport::TestCase
  setup do
    @old_root, GQL.root_class = GQL.root_class, FieldWithCalls
    @old_proc, GQL.root_target_proc = GQL.root_target_proc, -> _ { CallerTarget.new }
  end

  teardown do
    GQL.root_target_proc = @old_proc
    GQL.root_class = @old_root
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

  test "with call class given as string" do
    assert_equal({ result: ['booboo'] }, GQL.execute('call_class_as_string(2) { result }'))
    assert_equal({ me: { result: ['boobooboo'] } }, GQL.execute('{ me.call_class_as_string(3) { result } }'))
  end

  test "with connection result class" do
    assert FieldWithCalls.calls[:with_connection_result].result_class.has_field?(:edges)
  end

  test "with model-to-field mapping given as returns" do
    assert_equal({ a: 'a' }, GQL.execute('mapped_object_as_returns(1) { a }'))
    assert_equal({ me: { b: 'b' } }, GQL.execute('{ me.mapped_object_as_returns(42) { b } }'))
  end

  test "with call class returning mapping" do
    assert_equal({ a: 'a' }, GQL.execute('call_class_returning_mapping(1) { a }'))
    assert_equal({ me: { b: 'b' } }, GQL.execute('{ me.call_class_returning_mapping(42) { b } }'))
  end

  test "constants" do
    expected = {
      foo:                          FieldWithCalls::FooCall,
      foo_with_returns:             FieldWithCalls::FooWithReturnsCall,
      bar:                          FieldWithCalls::BarCall,
      bar_with_returns:             FieldWithCalls::BarWithReturnsCall,
      baz:                          FieldWithCalls::BazCall,
      baz_with_returns:             FieldWithCalls::BazWithReturnsCall,
      bam:                          FieldWithCalls::BamCall,
      bam_with_returns:             FieldWithCalls::BamWithReturnsCall,
      boo:                          FieldWithCalls::BooCall,
      boo_with_returns:             FieldWithCalls::BooWithReturnsCall,
      pow:                          FieldWithCalls::PowCall,
      no_execute_method:            FieldWithCalls::NoExecuteMethodCall,
      with_connection_result:       FieldWithCalls::WithConnectionResultCall,
      mapped_object_as_returns:     FieldWithCalls::MappedObjectAsReturnsCall,
      call_class_returning_mapping: FieldWithCalls::CallClassReturningMappingCall,
      call_class_as_string:         FieldWithCalls::CallClassAsStringCall
    }

    assert_equal expected, FieldWithCalls.calls
  end

  test "superclasses" do
    assert_equal GQL::Call,                         FieldWithCalls.calls[:foo].superclass
    assert_equal GQL::Call,                         FieldWithCalls.calls[:foo_with_returns].superclass
    assert_equal GQL::Call,                         FieldWithCalls.calls[:bar].superclass
    assert_equal GQL::Call,                         FieldWithCalls.calls[:bar_with_returns].superclass
    assert_equal CallClassWithoutResultClass,       FieldWithCalls.calls[:baz].superclass
    assert_equal CallClassWithoutResultClass,       FieldWithCalls.calls[:baz_with_returns].superclass
    assert_equal CallClassWithExplicitResultClass,  FieldWithCalls.calls[:bam].superclass
    assert_equal CallClassWithExplicitResultClass,  FieldWithCalls.calls[:bam_with_returns].superclass
    assert_equal CallClassWithImplicitResultClass,  FieldWithCalls.calls[:boo].superclass
    assert_equal CallClassWithImplicitResultClass,  FieldWithCalls.calls[:boo_with_returns].superclass
    assert_equal GQL::Call,                         FieldWithCalls.calls[:pow].superclass
    assert_equal CallClassWithoutExecuteMethod,     FieldWithCalls.calls[:no_execute_method].superclass
  end

  test "ids" do
    assert_equal :foo,                FieldWithCalls.calls[:foo].id
    assert_equal :foo_with_returns,   FieldWithCalls.calls[:foo_with_returns].id
    assert_equal :bar,                FieldWithCalls.calls[:bar].id
    assert_equal :bar_with_returns,   FieldWithCalls.calls[:bar_with_returns].id
    assert_equal :baz,                FieldWithCalls.calls[:baz].id
    assert_equal :baz_with_returns,   FieldWithCalls.calls[:baz_with_returns].id
    assert_equal :bam,                FieldWithCalls.calls[:bam].id
    assert_equal :bam_with_returns,   FieldWithCalls.calls[:bam_with_returns].id
    assert_equal :boo,                FieldWithCalls.calls[:boo].id
    assert_equal :boo_with_returns,   FieldWithCalls.calls[:boo_with_returns].id
    assert_equal :pow,                FieldWithCalls.calls[:pow].id
    assert_equal :no_execute_method,  FieldWithCalls.calls[:no_execute_method].id
  end

  test "inheritance" do
    a = FieldWithCalls.calls.keys
    b = Inherited.calls.keys

    assert_equal 16, a.size
    assert_equal 17, b.size

    assert_equal b, b & a.push(:bingo)
  end

  test "chaining" do
    expected = { value: ['foo', 'bar', 'bazbaz', 'foo', 'barbar', 'baz', 'foofoo', 'bar', 'baz'] }
    actual = GQL.execute('foo.bar().baz(2).foo().bar(2).baz.foo(2).bar.baz() { value }')

    assert_equal expected, actual
  end

  test "variables" do
    assert_equal 8, GQL.execute('pow(<x>, <y>) <x> = 2 <y> = 3')
    assert_equal 8, GQL.execute('{ me.pow(<x>, <y>) } <x> = 2 <y> = 3')[:me]
  end

  test "raises on variable not found" do
    assert_raises GQL::Errors::VariableNotFound, /<y>/ do
      GQL.execute '{ me.pow(<x>, <y>) } <x> = 2'
    end

    assert_nothing_raised do
      assert_equal 8, GQL.execute('pow(<x>, <y>) <y> = 3', {}, { x: 2 })
      assert_equal 8, GQL.execute('{ me.pow(<x>, <y>) } <x> = 2', {}, { y: 3 })[:me]
    end
  end

  test "no execute method" do
    assert_raises NotImplementedError do
      GQL.execute '{ me.no_execute_method(42) }'
    end
  end
end
