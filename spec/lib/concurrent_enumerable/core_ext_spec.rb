RSpec.describe Enumerable do
  describe '#parallel' do
    it 'should return a parallel instance' do
      expect([].parallel).to be_a Parallel
    end
  end
end
