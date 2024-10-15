package TempSensor {

  private import AADL::*;
  private import AADL_Project::*;
  private import AADL_Project::Time_Units::*;

  // TempSensor Thread
  part def TempSensor :> Thread {
    // features
    out port currentTemp : DataPort { out :> type : Temperature; }
    
    attribute :>> Dispatch_Protocol = Supported_Dispatch_Protocols::Periodic;
    attribute :>> Period = 1000 [millisecond];

    language "GUMBO" /*{
      integration
        guarantee Sensor_Temperature_Range:
          TempControlPeriodic::GUMBO__Library::inRange(currentTemp);

      initialize
        guarantee initializes:
          currentTemp.degrees == 72 [f32];
    }*/
  }

  // Data Types
  part def Temperature :> Data {

    part degrees : Base_Types::Float_32;

    language "GUMBO" /*{
      // data invariant
      // data invariants are assumed whenever value of the datatype is consumed
      //                  and must be proved whenever a value of the data type is constructed
      invariants
        inv AbsZero:
          degrees >= GUMBO_Periodic_Definitions::GUMBO__Library::absoluteZero();
    }*/
  }
}