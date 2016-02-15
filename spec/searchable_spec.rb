require 'searchable'

describe 'Searchable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Plant < SQLBase
      finalize!
    end

    class Human < SQLBase
      self.table_name = 'humans'

      finalize!
    end
  end

  it '#where searches with single criterion' do
    plants = Plant.where(name: 'Stalky')

    plant = plants.first

    expect(plants.length).to eq(1)
    expect(plant.name).to eq('Stalky')
  end

  it '#where can return multiple objects' do
    humans = Human.where(house_id: 1)
    expect(humans.length).to eq(2)
  end

  it '#where searches with multiple criteria' do
    humans = Human.where(fname: 'Todd', house_id: 1)
    expect(humans.length).to eq(1)

    human = humans[0]
    expect(human.fname).to eq('Todd')
    expect(human.house_id).to eq(1)
  end

  it "#where chains onto itself" do
    humans = Human.where(fname: 'Todd').where(house_id: 1)
    expect(humans.length).to eq(1)

    human = humans[0]
    expect(human.fname).to eq('Todd')
    expect(human.house_id).to eq(1)
  end

  it '#where returns a relation if nothing matches the criteria' do
    expect(Human.where(fname: 'Nowhere', lname: 'Man').class).to eq(Relation)
  end
end
