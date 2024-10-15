package CoolingFan {

  private import AADL::*;
  private import AADL_Project::*;
  private import AADL_Project::Time_Units::*;

  part def Fan :> Thread {
    // features
    in port fanCmd : EventDataPort { in :> type : FanCmd; }
    out port fanAck : EventDataPort { out :> type : FanAck; }
        
    attribute :>> Dispatch_Protocol = Supported_Dispatch_Protocols::Periodic;
    attribute :>> Period = 1000 [millisecond];
  }

  enum def FanCmd {
    enum On;
    enum Off;
  }
    
  enum def FanAck {
    Ok;
    Error;
  }
}
