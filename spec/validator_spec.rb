require 'validator'
require 'securerandom'

describe Validator do
  context 'validations: ' do
    class Test < Validator
      def test
        "test"
      end
    end

    describe 'presence' do
      x = Test.new
      it 'validates presence of a column' do
        (expect(x.validates :test, presence: true)).to eq(true)
      end
      it 'fails for a non-existent column' do
        (expect(x.validates :fake, presence: true)).to eq(false)
      end
    end

    describe 'length' do
      x = Test.new
      it 'validates minimum length of a column' do
        (expect(x.validates :test, length: {minimum: 3})).to eq(true)
        (expect(x.validates :test, length: {minimum: 5})).to eq(false)
      end
      it 'validates maximum length of a column' do
        (expect(x.validates :test, length: {maximum: 3})).to eq(false)
        (expect(x.validates :test, length: {maximum: 5})).to eq(true)
      end
    end
  end

end
