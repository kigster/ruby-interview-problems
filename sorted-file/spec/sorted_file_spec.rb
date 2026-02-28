# frozen_string_literal: true

require 'rspec'
require 'rspec/its'
require_relative '../lib/sorted_file'

RSpec.describe SortedFile do
  let(:file_names) { %w(a.png a.jpg a.pdf b.png c.txt e.iso f.bil g.tif h.sol) }
  let(:extensions) { %w(jpg txt png tif) }
  let(:files) { file_names.map { |f| described_class.new(f) } }

  let(:sorted_files) { files.sort }

  before { described_class.sort_extensions = extensions }

  context 'instantiated SortedFile array' do
    subject { files }
    its(:size) { should eq file_names.size }
  end

  context '#initialize' do
    subject { files.first }
    its(:file_name) { should eq file_names.first }

    context '#extension' do
      its(:extension) { should eq 'png' }
    end
  end

  context '#sort' do
    subject { sorted_files }

    let(:first_extension) { extensions.first }
    let(:regexp) { /\.#{first_extension}$/ }
    let(:matching_files) { file_names.grep(regexp) }

    it 'should get all jpg files' do
      expect(matching_files.first).to match regexp
    end

    its(:first) { should eq SortedFile.new('a.jpg') }

    context 'expected result' do
      subject { sorted_files.map(&:file_name) }
      let(:output) { %w(a.jpg c.txt a.png b.png g.tif a.pdf e.iso f.bil h.sol) }
      it { is_expected.to eq output }
    end
  end
end
