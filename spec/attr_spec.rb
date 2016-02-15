require 'attr'

describe AttrObject do
  before(:all) do
    class TestObject < AttrObject
      my_attr_reader :reader_only
      my_attr_writer :writer_only_1, :writer_only_2
      my_attr_accessor :accessor_1, :accessor_2
    end
  end

  after(:all) do
    Object.send(:remove_const, :TestObject)
  end

  subject(:test) { TestObject.new }

  describe '#my_attr_reader' do
    it 'defines a getter method' do
      expect(test).to respond_to(:reader_only)
    end

    it 'does not define a setter method' do
      expect(test).to_not respond_to(:reader_only=)
    end

    it 'reads the correct value from an instance variable' do
      x = 'x value'

      test.instance_variable_set('@reader_only', x)

      expect(test.reader_only).to eq(x)
    end
  end

  describe '#my_attr_writer' do
    it 'defines a setter method' do
      expect(test).to respond_to(:writer_only_1=)
      expect(test).to respond_to(:writer_only_2=)
    end
    it 'does not define a getter method' do
      expect(test).to_not respond_to(:writer_only)
    end
  end

  describe '#my_attr_accessor' do
    it 'defines a setter method' do
      expect(test).to respond_to(:accessor_1=)
      expect(test).to respond_to(:accessor_2=)
    end
    it 'defines a getter method' do
      expect(test).to respond_to(:accessor_1)
      expect(test).to respond_to(:accessor_2)
    end
  end
end
