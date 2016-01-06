class PopulateLanguages < ActiveRecord::Migration
  def up
    Language.create({id:1,name:'English',code:'EN'})
    Language.create({id:2,name:'Español',code:'ES'})
  end

  def down
    Language.destroy_all
  end
end
