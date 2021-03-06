describe Wayforpay::EncryptField do
  before do
    Wayforpay.configure do |config|
      config.merchant_account = 'merchantAccount'
      config.merchant_domain_name = 'merchantDomainName'
      config.encrypt_secret_key = 'secretKey'
    end
  end

  describe '.initialize' do
    let(:keys) { [:amount] }
    let(:attrs) { { amount: 123, currency: 'UAH' } }

    subject { described_class.new(keys, attrs) }

    it { expect(subject.keys).to eq keys }
    it { expect(subject.attrs).to eq attrs }
  end

  describe '.call' do
    let(:keys) { [:amount] }
    let(:attrs) { { amount: 1 } }
    let(:encrypt_field) { described_class.new(keys, attrs) }

    it "receives 'new' method for Wayforpay::EncryptField" do
      expect(described_class).to receive(:new).with(keys, attrs)
        .and_return(encrypt_field).once
      described_class.call(keys, attrs)
    end

    it "receives 'call' method for any instance of Wayforpay::EncryptField" do
      expect_any_instance_of(described_class).to receive(:call).once
      described_class.call(keys, attrs)
    end
  end

  describe '#call' do
    subject { described_class.new(keys, attrs).call }

    context 'in case params are HOLD_ENCRYPT_FIELDS and HOLD_ATTRS' do
      let(:keys) { Wayforpay::Constants::HOLD_ENCRYPT_FIELDS }
      let(:attrs) do
        Wayforpay::Constants.hold_params.merge({
          orderReference: 'new_order',
          amount: 1,
          currency: 'UAH',
          orderDate: 1514214411,
          productName: ['TRIP'],
          productPrice: [123],
          productCount: [1],
          recToken: 'recToken'
        })
      end

      it { is_expected.to eq '69306842abfb5424508a96674aa7bbaf' }
    end

    context 'in case params are REFUND_ENCRYPT_FIELDS and REFUND_ATTRS' do
      let(:keys) { Wayforpay::Constants::REFUND_ENCRYPT_FIELDS }
      let(:attrs) do
        Wayforpay::Constants.refund_params.merge({
          orderReference: 'new_order',
          amount: 2,
          currency: 'UAH',
          comment: 'Cancellation of a trip'
        })
      end

      it { is_expected.to eq '41b79af1557e7e84531e2e015f412ce1' }
    end

    context 'in case params are SETTLE_ENCRYPT_FIELDS and SETTLE_ATTRS' do
      let(:keys) { Wayforpay::Constants::SETTLE_ENCRYPT_FIELDS }
      let(:attrs) do
        Wayforpay::Constants.settle_params.merge({
          orderReference: 'new_order',
          amount: 3,
          currency: 'UAH'
        })
      end

      it { is_expected.to eq 'ba9a61da321d53b6a94dadeabf24eccf' }
    end

    context 'in case params are VERIFY_ENCRYPT_FIELDS and VERIFY_ATTRS' do
      let(:keys) { Wayforpay::Constants::VERIFY_ENCRYPT_FIELDS }
      let(:attrs) do
        Wayforpay::Constants.verify_params.merge({
          orderReference: 'verify_order',
          amount: 3,
          currency: 'UAH'
        })
      end

      it { is_expected.to eq 'e30d11bd5eec5f8f5fd980743d71d232' }
    end
  end

  describe '#signature_string' do
    subject { described_class.new(keys, attrs).signature_string }

    context 'in case params are HOLD_ENCRYPT_FIELDS and HOLD_ATTRS' do
      let(:keys) { Wayforpay::Constants::HOLD_ENCRYPT_FIELDS }
      let(:attrs) do
        Wayforpay::Constants.hold_params.merge({
          orderReference: 'new_order',
          amount: 1,
          currency: 'UAH',
          orderDate: 1514214411,
          productName: ['TRIP'],
          productPrice: [123, 987],
          productCount: [2],
          recToken: 'recToken'
        })
      end

      it { is_expected.to eq 'merchantAccount;merchantDomainName;new_order;1514214411;1;UAH;TRIP;2;123;987' }

      context 'in case any required fields are missing' do
        before { attrs.delete(:orderDate) }

        it { is_expected.to eq 'merchantAccount;merchantDomainName;new_order;1;UAH;TRIP;2;123;987' }
      end
    end

    context 'in case params are REFUND_ENCRYPT_FIELDS and REFUND_ATTRS' do
      let(:keys) { Wayforpay::Constants::REFUND_ENCRYPT_FIELDS }
      let(:attrs) do
        Wayforpay::Constants.refund_params.merge({
          orderReference: 'new_order',
          amount: 2,
          currency: 'UAH',
          comment: 'Cancellation of a trip'
        })
      end

      it { is_expected.to eq 'merchantAccount;new_order;2;UAH' }

      context 'in case any required fields are missing' do
        before { attrs.delete(:amount) }

        it { is_expected.to eq 'merchantAccount;new_order;UAH' }
      end
    end

    context 'in case params are SETTLE_ENCRYPT_FIELDS and SETTLE_ATTRS' do
      let(:keys) { Wayforpay::Constants::SETTLE_ENCRYPT_FIELDS }
      let(:attrs) do
        Wayforpay::Constants.settle_params.merge({
          orderReference: 'new_order',
          amount: 3,
          currency: 'UAH'
        })
      end

      it { is_expected.to eq 'merchantAccount;new_order;3;UAH' }

      context 'in case any required fields are missing' do
        before { attrs.delete(:orderReference) }

        it { is_expected.to eq 'merchantAccount;3;UAH' }
      end
    end

    context 'in case params are VERIFY_ENCRYPT_FIELDS and VERIFY_ATTRS' do
      let(:keys) { Wayforpay::Constants::VERIFY_ENCRYPT_FIELDS }
      let(:attrs) do
        Wayforpay::Constants.verify_params.merge({
          orderReference: 'verify_order',
          amount: 3,
          currency: 'UAH',
          card: '4111111111111111',
          expMonth: '11',
          expYear: '2020',
          cardCvv: '111',
          cardHolder: 'TARAS BULBA'
        })
      end

      it do
        is_expected.to eq 'merchantAccount;merchantDomainName;verify_order;3;UAH'
      end

      context 'in case any required fields are missing' do
        before { attrs.delete(:orderReference) }

        it { is_expected.to eq 'merchantAccount;merchantDomainName;3;UAH' }
      end
    end
  end
end
