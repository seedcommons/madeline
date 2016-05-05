require 'rails_helper'

shared_examples_for 'division_owned_scope' do |record_type|

  let!(:parent_division) { create(:division) }
  let!(:division) { create(:division, parent: parent_division) }
  let!(:child_division) { create(:division, parent: division) }

  let(:parent_divison_record) { create(record_type, division: parent_division) }
  let(:division_record) { create(record_type, division: division) }
  let(:child_division_record) { create(record_type, division: child_division) }

  describe 'Scope' do
    context 'being a member of a division' do
      let(:user) { create(:user, :member, division: division) }
      it 'can not resolve records owned by parent division' do
        expect(record_id_scope(record_type, user, parent_divison_record.id)).not_to exist
      end
      it 'can resolve records owned by division' do
        expect(record_id_scope(record_type, user, division_record.id)).to exist
      end
      it 'can resolve records owned by child division' do
        expect(record_id_scope(record_type, user, child_division_record.id)).to exist
      end
    end

    context 'being an admin of a division' do
      let(:user) { create(:user, :admin, division: division) }
      it 'can not resolve records owned by parent division' do
        expect(record_id_scope(record_type, user, parent_divison_record.id)).not_to exist
      end
      it 'can resolve records owned by division' do
        expect(record_id_scope(record_type, user, division_record.id)).to exist
      end
      it 'can resolve records owned by child division' do
        expect(record_id_scope(record_type, user, child_division_record.id)).to exist
      end
    end

    context 'being owned by, but without roll association with a division' do
      let(:user) { create(:user, division: division) }
      it 'can not resolve any records' do
        expect(record_scope(record_type, user)).not_to exist
      end
    end

    def record_id_scope(record_type, user, record_id)
      record_scope(record_type, user, id: record_id)
    end

    def record_scope(record_type, user, conditions = nil)
      scope_class(record_type).new(user, record_class(record_type).where(conditions)).resolve
    end

    def scope_class(record_type)
      "#{record_type.to_s.camelize}Policy::Scope".constantize
    end
  end

end
