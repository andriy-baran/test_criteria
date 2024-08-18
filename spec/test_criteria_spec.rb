# frozen_string_literal: true

RSpec.describe TestCriteria do
  it 'does something useful' do
    mod = Module.new do
      def to_hex(number)
        number.to_s(16)
      end
    end
    TestCriteria::ContextDefinition.extend mod
    TestCriteria.define do
      context(:show) do |b|
        b.b = to_hex(12)
        b.a = 'nome'
        b.c = [1, 2, 3]
        b.d do |d|
          d.c = { some: :value }
        end
      end
    end
    show = TestCriteria[:show]
    expect(show.b).to eq 'c'
    expect(show.a).to eq 'nome'
    expect(show.c).to eq [1, 2, 3]
    expect(show.d.c).to eq({ some: :value })
    expect { TestCriteria[:free] }.to raise_error(TestCriteria::ContextNotRegisterdError)
  end
end
