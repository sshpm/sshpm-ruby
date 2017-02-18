describe SSHPM::Tasks::Builder do
  it "builds empty Hash" do
    builders = [
      SSHPM::Tasks::Builder.new,
      SSHPM::Tasks::Builder.build,
      SSHPM::Tasks::Builder.build do
      end
    ]

    builders.each do |builder|
      expect(builder.attributes).to eq({})
    end
  end

  it "builds small Hash" do
    builder = SSHPM::Tasks::Builder.build do
      some_string 'string_value'
      some_integer 9
      some_array []
    end

    expect(builder.attributes).to eq({
      :some_string => 'string_value',
      :some_integer => 9,
      :some_array => []
    })
  end
end
