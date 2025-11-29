require 'jwt'

RSpec.describe JsonWebToken do
  let(:payload) { { user_id: 123 } }
  let(:secret_key) { Rails.application.secret_key_base }

  describe '.encode' do
    it 'encodes the payload with an expiration' do
      token = described_class.encode(payload)
      decoded_payload = JWT.decode(token, secret_key)[0]

      expect(decoded_payload['user_id']).to eq(123)
      expect(decoded_payload).to have_key('exp')
      expect(Time.at(decoded_payload['exp'])).to be > Time.now
    end

    it 'sets a custom expiration if provided' do
      exp = 2.hours.from_now
      token = described_class.encode(payload, exp)
      decoded_payload = JWT.decode(token, secret_key)[0]

      expect(Time.at(decoded_payload['exp'])).to be_within(1.second).of(exp)
    end
  end

  describe '.decode' do
    context 'with a valid token' do
      let(:token) { described_class.encode(payload) }

      it 'decodes the token and returns the payload as HashWithIndifferentAccess' do
        decoded = described_class.decode(token)
        expect(decoded).to be_a(HashWithIndifferentAccess)
        expect(decoded[:user_id]).to eq(123)
      end
    end

    context 'with an expired token' do
      let(:expired_token) do
        described_class.encode(payload, 1.hour.ago)
      end

      it 'raises TokenExpiredError' do
        expect { described_class.decode(expired_token) }.to raise_error(::Errors::TokenExpiredError)
      end
    end

    context 'with an invalid token' do
      let(:invalid_token) { 'invalid.token.here' }

      it 'raises TokenInvalidError' do
        expect { described_class.decode(invalid_token) }.to raise_error(::Errors::TokenInvalidError)
      end
    end
  end
end
