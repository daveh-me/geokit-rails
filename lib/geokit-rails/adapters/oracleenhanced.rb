module Geokit
  module Adapters
    class OracleEnhanced < Abstract
     
     def self.load(klass)
       klass.connection.execute <<-EOS
       create or replace function radians(angle_in_degrees in number) return number is
       begin
         return angle_in_degrees * 3.141592653589793 / 180; 
        end radians;
       EOS
     end

      def sphere_distance_sql(lat, lng, multiplier)
        %|
          (ACOS(least(1,COS(#{lat})*COS(#{lng})*COS(RADIANS(#{qualified_lat_column_name}))*COS(RADIANS(#{qualified_lng_column_name}))+
          COS(#{lat})*SIN(#{lng})*COS(RADIANS(#{qualified_lat_column_name}))*SIN(RADIANS(#{qualified_lng_column_name}))+
          SIN(#{lat})*SIN(RADIANS(#{qualified_lat_column_name}))))*#{multiplier})
         |
      end
      
      def flat_distance_sql(origin, lat_degree_units, lng_degree_units)
        %|
          SQRT(POWER(#{lat_degree_units}*(#{origin.lat}-#{qualified_lat_column_name}),2)+
          POWER(#{lng_degree_units}*(#{origin.lng}-#{qualified_lng_column_name}),2))
         |
      end
    end
  end
end