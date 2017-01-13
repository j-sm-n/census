require 'rails_helper'
RSpec.describe User, type: :model do
  it { should validate_presence_of :first_name }
  it { should validate_presence_of :last_name }
  it { should have_many(:affiliations).dependent(:destroy) }
  it { should have_many(:groups).through(:affiliations) }
  it { should have_many(:user_roles).dependent(:destroy) }
  it { should have_many(:roles).through(:user_roles) }
  it { should have_many(:invitations) }
  it { should have_many(:oauth_applications) }

  # testing paperclip
  it { should have_attached_file(:image) }
  it { should validate_attachment_content_type(:image).
                allowing('image/png', 'image/gif', 'image/png').
                rejecting('text/plain', 'text/xml') }

  it "has a full name" do
    user = create(:user)
    expect(user.full_name).to eq("#{user.first_name} #{user.last_name}")
  end

  it "can report out its roles" do
    user = create :user

    expect(user.list_roles).to eq("enrolled")
  end

  it "can find specific role associated with it" do
    user = create :user
    role_1 = create :role, name: "enrolled"
    role_2 = create :role, name: "active student"
    user.roles << [role_1, role_2]

    expect(user.has_role?("enrolled")).to be(true)
    expect(user.has_role?("active student")).to be(true)
    expect(user.has_role?("admin")).to be(false)
  end

  it "can return users by name search" do
    dan  = create :user, first_name: "Dan", last_name: "Broadbent"
    susi = create :user, first_name: "Susi", last_name: "Irwin"
    nate = create :user, first_name: "Nate", last_name: "Anderson"

    users = User.search_by_name("an")

    expect(users.sort).to eq([dan, nate])
  end

  it "rejects invalid twitter usernames" do
    okay = build(:user, twitter: "_calaway_")
    invalid_characters = build(:user, twitter: "_ca!away_")
    too_long = build(:user, twitter: "1234567890123456")

    expect(okay.valid?).to be true
    expect(invalid_characters.valid?).to be false
    expect(too_long.valid?).to be false
  end

  it "rejects invalid LinkedIn usernames" do
    okay = build(:user, linked_in: "calaway")
    invalid_characters = build(:user, linked_in: "ca!away_")
    too_short = build(:user, linked_in: "1234")
    too_long = build(:user, linked_in: "1234567890123456789012345678901")

    expect(okay.valid?).to be true
    expect(invalid_characters.valid?).to be false
    expect(too_short.valid?).to be false
    expect(too_long.valid?).to be false
  end

  it "sets its default role before saving" do
    user = create(:user)

    expect(user.has_role?('enrolled')).to eq(true)
  end
end
