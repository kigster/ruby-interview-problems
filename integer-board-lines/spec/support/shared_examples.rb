# frozen_string_literal: true

# Shared examples for objects that can be validated
#
# @example Usage
#   it_behaves_like 'a validatable object' do
#     let(:valid_subject) { ValidClass.new(valid_params) }
#     let(:invalid_subject) { ValidClass.new(invalid_params) }
#   end
RSpec.shared_examples 'a validatable object' do
  describe '#valid?' do
    context 'when object is valid' do
      subject { valid_subject }
      its(:valid?) { is_expected.to be true }
    end

    context 'when object is invalid' do
      subject { invalid_subject }
      its(:valid?) { is_expected.to be false }
    end
  end
end

# Shared examples for objects that have coordinate boundaries
#
# @example Usage
#   it_behaves_like 'an object with coordinate boundaries' do
#     let(:subject_with_bounds) { ObjectWithBounds.new(x1, y1, x2, y2) }
#   end
RSpec.shared_examples 'an object with coordinate boundaries' do
  describe 'coordinate boundaries' do
    subject { subject_with_bounds }

    its(:min_x) { is_expected.to be_a(Integer) }
    its(:max_x) { is_expected.to be_a(Integer) }
    its(:min_y) { is_expected.to be_a(Integer) }
    its(:max_y) { is_expected.to be_a(Integer) }

    it 'maintains proper boundary relationships' do
      expect(subject.min_x).to be <= subject.max_x
      expect(subject.min_y).to be <= subject.max_y
    end
  end
end

# Shared examples for objects that have dimensions
#
# @example Usage
#   it_behaves_like 'an object with dimensions' do
#     let(:dimensional_subject) { DimensionalClass.new(width: 10, height: 5) }
#   end
RSpec.shared_examples 'an object with dimensions' do
  describe 'dimensions' do
    subject { dimensional_subject }

    its(:width) { is_expected.to be_a(Integer) }
    its(:height) { is_expected.to be_a(Integer) }
    its(:size) { is_expected.to eq(subject.width * subject.height) }

    it 'has positive dimensions' do
      expect(subject.width).to be > 0
      expect(subject.height).to be > 0
    end
  end
end

# Shared examples for calculation methods
#
# @example Usage
#   it_behaves_like 'basic calculation methods' do
#     let(:calc_subject) { ClassWithCalc.new }
#   end
RSpec.shared_examples 'basic calculation methods' do
  describe 'calculation methods' do
    subject { calc_subject }

    describe '#min' do
      it 'returns the smaller value' do
        expect(subject.min(5, 10)).to eq(5)
        expect(subject.min(10, 5)).to eq(5)
        expect(subject.min(-5, 0)).to eq(-5)
      end
    end

    describe '#max' do
      it 'returns the larger value' do
        expect(subject.max(5, 10)).to eq(10)
        expect(subject.max(10, 5)).to eq(10)
        expect(subject.max(-5, 0)).to eq(0)
      end
    end
  end
end
