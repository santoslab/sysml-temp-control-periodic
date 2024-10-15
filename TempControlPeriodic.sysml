//@ HAMR: --platform JVM --package-name tc --runtime-monitoring

package TempControlPeriodic {

  private import AADL::*;
  private import AADL_Project::*;
  private import AADL_Project::Time_Units::*;
  private import TempSensor::*;
  private import CoolingFan::*;

  language "GUMBO" /*{
    library
      functions
        def inRange(temp: TempSensor::Temperature): Base_Types::Boolean :=
          temp.degrees >= -40.0 [f32] and temp.degrees <= 122.0 [f32];
  }*/

  part def TempControlSystem :> System {
    // subcomponents
    part tcpoc : TempControlProcess;
  }
    
  part def TempControlProcess :> Process {
    // subcomponents
    part tempSensor : TempSensor;
    part tempControl : TempControl;
    part fan : CoolingFan::Fan;
    part operatorInterface : OperatorInterface;

    // connections
    connection ctTStoTC : PortConnection connect tempSensor.currentTemp to tempControl.currentTemp;
    connection ctTStoOI : PortConnection connect tempSensor.currentTemp to operatorInterface.currentTemp;
    connection fcTCtoF : PortConnection connect tempControl.fanCmd to fan.fanCmd;
    connection faFtoTC : PortConnection connect fan.fanAck to tempControl.fanAck;
    connection spOItoTC : PortConnection connect operatorInterface.setPoint to tempControl.setPoint;
  }

  part def TempControl :> Thread {
    // features
    in port currentTemp : DataPort { in :> type : Temperature; }
    in port fanAck : DataPort { in :> type : FanAck; }
    in port setPoint : DataPort { in :> type : SetPoint; }
    out port fanCmd : DataPort { out :> type : FanCmd; }

    attribute :>> Dispatch_Protocol = Supported_Dispatch_Protocols::Periodic;
    attribute :>> Period = 1000 [millisecond];

    language "GUMBO" /*{

      state
        latestFanCmd: FanCmd;

      integration
        assume currentTempRange:
          (currentTemp.degrees >= -40.0 [f32]) & (currentTemp.degrees <= 122.0 [f32]);

      initialize
        modifies (latestFanCmd);
        guarantee initLatestFanCmd "Initialize state variable":
          // provide initial value for state variable and out data port
          latestFanCmd == CoolingFan::FanCmd.Off;

        guarantee initFanCmd "Initial fan command":
          // provide initial value for state variable and out data port
          fanCmd == CoolingFan::FanCmd.Off;

        // illustrate cases syntax
        compute
          modifies (latestFanCmd);

          guarantee altCurrentTempLTSetPoint "If current temperature is less than
                                             |the current low set point, then the fan state shall be Off" :
            '->:'(currentTemp.degrees < setPoint.low.degrees,
                  latestFanCmd == CoolingFan::FanCmd.Off and fanCmd == CoolingFan::FanCmd.Off);

          guarantee altCurrentTempGTSetPoint "If current temperature is greater than
                                             |the current high set point, then the fan state shall be On":
            '->:'(currentTemp.degrees > setPoint.high.degrees,
                  latestFanCmd == CoolingFan::FanCmd.On & fanCmd == CoolingFan::FanCmd.On);

          guarantee altCurrentTempInRange "If current temperature is greater than or equal to the
                                          |current low set point and less than or equal to the current high set point,
                                          |then the current fan state is maintained." :
            '->:'(currentTemp.degrees >= setPoint.low.degrees & currentTemp.degrees <= setPoint.high.degrees,
                  latestFanCmd == In(latestFanCmd) & fanCmd == latestFanCmd);

          // alternative style using cases

          compute_cases
            case currentTempLTSetPoint "If current temperature is less than
                                       |the current low set point, then the fan state shall be Off":
              assume currentTemp.degrees < setPoint.low.degrees;
              guarantee (latestFanCmd == CoolingFan::FanCmd.Off) & (fanCmd == CoolingFan::FanCmd.Off);

            case currentTempGTSetPoint "If current temperature is greater than
                                       |the current high set point, then the fan state shall be On":
              assume currentTemp.degrees > setPoint.high.degrees;
              guarantee (latestFanCmd == CoolingFan::FanCmd.On) & (fanCmd == CoolingFan::FanCmd.On);

            case currentTempInRange "If current temperature is greater than or equal to the
                                    |current low set point and less than or equal to the current high set point,
                                    |then the current fan state is maintained.":
              assume (currentTemp.degrees >= setPoint.low.degrees) & (currentTemp.degrees <= setPoint.high.degrees);
              guarantee
                (latestFanCmd == In(latestFanCmd)) &
                (fanCmd == latestFanCmd);

    }*/
  }

  part def OperatorInterface :> Thread {
    // features
    in port currentTemp : DataPort { in :> type : Temperature; }
    out port setPoint : EventDataPort { out :> type : SetPoint; }
    
    attribute :>> Dispatch_Protocol = Supported_Dispatch_Protocols::Periodic;
    attribute :>> Period = 1000 [millisecond];
  }


  part def SetPoint :> Data {
    part low : Temperature;
    part high : Temperature;

    language "GUMBO" /*{
      invariants
        inv SetPoint_Data_Invariant:
          (low.degrees >= 50.0 [f32]) &
          (high.degrees <= 110.0 [f32]) &
          (low.degrees <= high.degrees);
    }*/
  }
}
