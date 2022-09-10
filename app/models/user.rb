class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :permissions
  has_many :itineraries, through: :permissions

  def full_name
    "#{first_name} #{last_name}"
  end

  def relevant_itineraries(params)
    @params_data = (1..params["passenger_group_count"].to_i).to_a.map{|i| group_params(params, i)}
    result = {}
    i = itineraries
      .filter { |i| check_relevant(i, params) }
      .map { |i| [i.destination.city_code, i] }
      .to_h
    i
  end

  def group_params(params, i)
    {
      origin: params["origin_city#{i}"],
      adults: params["adults#{i}"].to_i,
      children: params["children#{i}"].to_i
    }
  end

  def check_relevant(i, params)
    i.start_date.to_s == params["start_date"] &&
        i.end_date.to_s == params["end_date"] &&
          i.passenger_groups.map(&:to_param_hash) == @params_data
  end
end
