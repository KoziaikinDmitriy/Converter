require 'spec_helper'

RSpec.describe Converter do
  let(:currency_rates) do
  {
    usd: 1.11,
    bitcoin: 0.0047
  }
end
  it 'has a version number' do
    expect(Converter::VERSION).not_to be nil
  end

  it 'should setup rates' do
    Converter::Converter.conversion_rates('EUR', currency_rates)

    expect(Converter::Converter.base_currency).to eq('EUR')
    expect(Converter::Converter.currency_rates).to eq(currency_rates.merge(eur: 1))
  end

  it 'should create Converter instance' do
    fifty_eur = Converter::Converter.new(50, 'EUR')

    expect(fifty_eur.amount).to eq(50)
    expect(fifty_eur.currency).to eq('EUR')
    expect(fifty_eur.inspect).to eq('50.00 EUR')
  end

  it 'should create Converter instance for float' do
    fifty_eur = Converter::Converter.new(50.46, 'EUR')

    expect(fifty_eur.amount).to eq(50.46)
    expect(fifty_eur.currency).to eq('EUR')
    expect(fifty_eur.inspect).to eq('50.46 EUR')
  end

  it 'should convert to other currency' do
    Converter::Converter.conversion_rates('EUR', currency_rates)

    fifty_eur = Converter::Converter.new(50, 'EUR')

    dollar_result = fifty_eur.convert_to('USD')

    expect(dollar_result.amount).to eq(55.50)
    expect(dollar_result.currency).to eq('USD')
    expect(dollar_result.inspect).to eq('55.50 USD')
  end

  it 'should return itself when converts to the same currency' do
    Converter::Converter.conversion_rates('EUR', currency_rates)

    fifty_eur = Converter::Converter.new(50, 'EUR')

    other_eur = fifty_eur.convert_to('EUR')

    p fifty_eur
    expect(other_eur.amount).to eq(50)
    expect(other_eur.currency).to eq('EUR')
    expect(other_eur.inspect).to eq('50.00 EUR')
  end

  it 'should raise an exception if no proper currency is available' do
    Converter::Converter.conversion_rates(:eur, currency_rates)

    fifty_eur = Converter::Converter.new(50, 'EUR')
    expect { fifty_eur.convert_to('RUB') }.to raise_error(Converter::ConverterError)
  end

  it 'should plus the Converter' do
    Converter::Converter.conversion_rates('EUR', currency_rates)

    fifty_eur = Converter::Converter.new(50, 'EUR')
    twenty_dollars = Converter::Converter.new(20, 'USD')

    result = fifty_eur + twenty_dollars

    expect(result.amount).to eq(68.02)
    expect(result.currency).to eq('EUR')
    expect(result.inspect).to eq('68.02 EUR')
  end

  it 'should plus the number' do
    Converter::Converter.conversion_rates('EUR', currency_rates)

    fifty_eur = Converter::Converter.new(50, 'EUR')

    result = fifty_eur + 20

    expect(result.amount).to eq(70)
    expect(result.currency).to eq('EUR')
    expect(result.inspect).to eq('70.00 EUR')
  end

  it 'should minus the Converter' do
    Converter::Converter.conversion_rates('EUR', currency_rates)

    fifty_eur = Converter::Converter.new(50, 'EUR')
    twenty_dollars = Converter::Converter.new(20, 'USD')

    result = fifty_eur - twenty_dollars

    expect(result.amount).to eq(31.98)
    expect(result.currency).to eq('EUR')
    expect(result.inspect).to eq('31.98 EUR')
  end

  it 'should minus the number' do
    Converter::Converter.conversion_rates('EUR', currency_rates)

    fifty_eur = Converter::Converter.new(50, 'EUR')

    result = fifty_eur - 20

    expect(result.amount).to eq(30)
    expect(result.currency).to eq('EUR')
    expect(result.inspect).to eq('30.00 EUR')
  end

  it 'should multi by number' do
    fifty_eur = Converter::Converter.new(50, 'EUR')
    result = fifty_eur * 2

    expect(result.amount).to eq(100)
    expect(result.currency).to eq('EUR')
    expect(result.inspect).to eq('100.00 EUR')
  end

  it 'should divide by number' do
    fifty_eur = Converter::Converter.new(50, 'EUR')
    result = fifty_eur / 2

    expect(result.amount).to eq(25)
    expect(result.currency).to eq('EUR')
    expect(result.inspect).to eq('25.00 EUR')
  end

  it 'should compare the Converter' do
    Converter::Converter.conversion_rates('EUR', currency_rates)
    twenty_dollars = Converter::Converter.new(20, 'USD')
    fifty_eur = Converter::Converter.new(50, 'EUR')

    expect(twenty_dollars).to eq(Converter::Converter.new(20, 'USD'))
    expect(twenty_dollars).to_not eq(Converter::Converter.new(30, 'USD'))

    expect(twenty_dollars != Converter::Converter.new(30, 'USD')).to be_truthy

    fifty_eur_in_usd = fifty_eur.convert_to('USD')
    expect(fifty_eur_in_usd).to eq(fifty_eur)

    expect(twenty_dollars).to be > Converter::Converter.new(5, 'USD')
    expect(twenty_dollars).to be < fifty_eur
  end
end
