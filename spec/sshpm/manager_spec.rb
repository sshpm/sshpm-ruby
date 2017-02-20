require 'spec_helper'

describe SSHPM::Manager do
  it "Newly created manager has no tasks" do
    expect(SSHPM::Manager.new.tasks).to eq([])
  end

  it "If not specified, host must be nil" do
    expect(SSHPM::Manager.new.host).to eq(nil)
  end
  
  context "add_user" do
    before :all do
      @manager = SSHPM::Manager.new
    end

    it "After each call the number of tasks increases by 1" do

      (1..10).each do |index|
        @manager.add_user do
          name Faker::Internet.user_name
          password Faker::Internet.password
        end

        expect(@manager.tasks.size).to eq(index)
      end
    end

    it "The resulting managare has 10 tasks" do
      expect(@manager.tasks.size).to eq(10)
    end

    it "All items in the resulting tasks are AddUser" do
      @manager.tasks.each do |task|
        expect(task).to be_a(SSHPM::Tasks::AddUser)
      end
    end
  end

  context "remove_user" do
    before :all do
      @manager = SSHPM::Manager.new
    end

    it "After each call the number of tasks increases by 1" do

      (1..10).each do |index|
        @manager.remove_user do
          name Faker::Internet.user_name
          password Faker::Internet.password
        end

        expect(@manager.tasks.size).to eq(index)
      end
    end

    it "The resulting managare has 10 tasks" do
      expect(@manager.tasks.size).to eq(10)
    end

    it "All items in the resulting tasks are RemoveUser" do
      @manager.tasks.each do |task|
        expect(task).to be_a(SSHPM::Tasks::RemoveUser)
      end
    end
  end
end
