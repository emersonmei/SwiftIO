/**
The Timer class is used to set the occasion to raise the interrupt.

*/
public final class Timer {
    private var obj: TimerObject
    private var callback: (()->Void)?

    private var mode: Mode {
        willSet {
            obj.timerType = newValue.rawValue
        }
    }

    private var period: Int {
        willSet {
            obj.period = Int32(newValue)
        }
    }

    private func objectInit() {
        obj.timerType = mode.rawValue
        obj.period = Int32(period)
        swiftHal_timerInit(&obj)
    }

    /**
     Intialize a timer.
     */
    public init() {
        self.mode = .period
        self.period = 0

        obj = TimerObject()
        objectInit()
    }

    deinit {
        swiftHal_timerDeinit(&obj)
    }

    /**
     Execute a designated task  at a scheduled time interval. The task should be executed in a very short time, usually in nanoseconds.
     - Parameter ms: **REQUIRED** The time period set for the interrupt.
     - Parameter mode: **OPTIONAL** The times that the interrupt will occur: once or continuous.
     - Parameter start: **OPTIONAL** By default, the interrupt will start directly to work.
     - Parameter callback: **REQUIRED** A void function without a return value.
     
     #### Usage Example
     
     ````
     let timer = Timer()
     let led = DigitalOut(.GREEN)
     ````
     The setInterrupt function can be written as following:
     ````
     func toggleLed() {
         led.toggle()
     }
     timer.setInterrupt(ms: 1000, toggleLed)
     ````
     **or**
     ````
     timer.setInterrupt(ms: 1000) {
         led.toggle()
     }
     ````
     */
    public func setInterrupt(ms period: Int,
                            mode: Mode = .period,
                            start: Bool = true,
                            _ callback: @escaping ()->Void) {
        let initalSet = self.callback == nil ? true : false

        self.period = period
        self.mode = mode
        self.callback = callback
        swiftHal_timerAddSwiftMember(&obj, getClassPtr(self)) {(ptr)->Void in
            let mySelf = Unmanaged<Timer>.fromOpaque(ptr!).takeUnretainedValue()
            mySelf.callback!()
        }
        if start {
            swiftHal_timerStart(&obj)
        } else if initalSet == false {
            swiftHal_timerStop(&obj)
        }
    }

    /**
     Start the timer.
     */
    public func start() {
        swiftHal_timerStart(&obj)
    }

    /**
     Stop the timer.
     */
    public func stop() {
        swiftHal_timerStop(&obj)
    }

    /**
     Reset the timer. The timer will restart from 0.
     */
    public func reset() {
        swiftHal_timerCount(&obj)
    }

}


extension Timer {
    /**
     There are two timer modes: if set to `oneShot`, the interrupt happens only once; if set to `period`, the interrupt happens continuously.
     */
    public enum Mode: UInt8 {
        case oneShot, period
    }
}
