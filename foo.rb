def assert_object_ids(list)
  same_count = list.find_all { |obj|
    obj.memory_location == obj.object_id
  }.count
  list.count - same_count
end

def big_list
  1000.times.map { Object.new }
end

list_of_objects = big_list

ids       = list_of_objects.map(&:object_id)
addresses = list_of_objects.map(&:memory_location)

p assert_object_ids(list_of_objects) # should be 0

GC.compact

p assert_object_ids(list_of_objects) # should be > 0

new_ids = list_of_objects.map(&:object_id)
p ids == new_ids # Rule 1: Must be consistent ( should be true )

new_object = nil

loop do
  new_object = Object.new
  if addresses.include? new_object.memory_location
    puts "found one!"
    break
  end
end

# This is the object that used to be in new_object's position
moved_object = list_of_objects[addresses.index(new_object.memory_location)]

# These should not be the same.  Rule 2 is broken :(
p moved_object.object_id
puts "EHSOITNESHOITNHSEOIN"
p new_object.object_id
