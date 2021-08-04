shared_examples_for "translatable" do |attributes|
  let(:translatable_model) do
    model = create(described_class.to_s.underscore)
    # purge any translations created by the original factory since we'll be creating new ones below
    model.translations.destroy_all
    model
  end

  attributes.each do |attribute|
    context "with locale set to english" do
      let!(:current_locale) { I18n.locale = :en }

      context "with translation in locale" do
        let!(:translation) do
          result = create(:translation,
            translatable: translatable_model,
            translatable_attribute: attribute,
            locale: current_locale
          )
          # need to update the cached association
          translatable_model.reload
          result
        end

        it "creates #{attribute} method which gets translation for current locale" do
          fetched_translation = translatable_model.send(attribute.to_sym)
          expect(fetched_translation).to be_a Translation
          expect(fetched_translation.locale).to eq current_locale.to_s
          expect(fetched_translation.text).to eq translation.text
        end
      end

      context "with no translation" do
        it "#{attribute} method returns nil" do
          fetched_translation = translatable_model.send(attribute.to_sym)
          expect(fetched_translation).to be_nil
        end
      end

      context "with foreign translation" do
        let!(:translation) do
          result = create(:translation,
            translatable: translatable_model,
            translatable_attribute: attribute,
            text: Faker::Lorem.paragraph(sentence_count = 2),
            locale: :es
          )
          translatable_model.reload
          result
        end

        it "#{attribute} method returns any available translation" do
          fetched_translation = translatable_model.send(attribute.to_sym)
          expect(fetched_translation.text).to eq translation.text
        end
      end

    end

  end

  describe "#{described_class} assignments on create" do
    let!(:current_locale) { I18n.locale = :en }
    let(:translatable_model) do
      attribute_hash = {}
      attributes.each do |attribute|
        attribute_hash[attribute] = Faker::Hipster.sentence
      end
      create(described_class.to_s.underscore, attribute_hash)
    end

    attributes.each do |attribute|
      it "has translations in current locale for #{attribute}" do
        fetched_translation = translatable_model.send(attribute)
        expect(fetched_translation).to be_a Translation
        expect(fetched_translation.locale).to eq "en"
      end
    end
  end
end
