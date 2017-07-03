module Converter
  # main class for Converter gem
  class Converter
    attr_reader :amount

    class << self
      attr_reader :currency_rates

      def conversion_rates(base_currency, currency_rates)
        @base_currency = base_currency.to_sym.downcase
        @currency_rates = currency_rates.merge(Hash[@base_currency, 1])
      end

      def base_currency
        @base_currency.to_s.upcase
      end
    end

    def initialize(amount, currency)
      @amount = amount.round(2)
      @currency = currency.to_sym.downcase
    end

    def currency
      @currency.to_s.upcase
    end

    def inspect
      "#{format('%.2f', @amount)} #{@currency.to_s.upcase}"
    end

    def convert_to(new_currency)
      new_currency = new_currency.to_sym.downcase
      return self if @currency == new_currency

      if @currency == Converter.base_currency
        Converter.new(@amount * Converter.currency_rates.fetch(new_currency),
                  new_currency)
      else
        new_amount = (@amount / Converter.currency_rates.fetch(@currency)) *
                     Converter.currency_rates.fetch(new_currency)

        Converter.new(new_amount, new_currency)
      end
    rescue KeyError
      raise ::Converter::ConverterError, 'Can\'t find this currency. ' \
        "Available currencies are: #{Converter.currency_rates.keys.join(' ')}"
    end

    %i[+ -].each do |method|
      define_method(method) do |other|
        if other.is_a?(Converter)
          Converter.new(@amount.send(method, other.convert_to(@currency.to_sym.downcase).amount),
                    @currency)
        else
          Converter.new(@amount.send(method, other), @currency)
        end
      end
    end

    %i[* /].each do |method|
      define_method(method) do |number|
        Converter.new(@amount.send(method, number), @currency)
      end
    end

    %i[== > < >= <= !=].each do |method|
      define_method(method) do |other|
        @amount.to_f.round(2)
               .send(method, other.convert_to(@currency.to_sym.downcase).amount.to_f.round(2))
      end
    end
  end
end
