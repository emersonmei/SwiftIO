/**
 The PWMOut class is used to vary the output voltage by controlling the duration of high output in the time period on the pin.

 ### Example: Light a LED

 ````
 import SwiftIO
 
 // Initiate a PWMOut to Pin PWM0.
 let led = PWMOut(Id.PWM0)
 
 // Set the brightness of the LED by setting the duty cycle.
 while true {
     led.setDutycycle(0.5)
 }
 ````
*/
public final class PWMOut {
    private var obj: PWMOutObject

    private let id: IdName
    private var usPeriod: Int {
        willSet {
            obj.period = UInt32(newValue)
        }
    }
    private var usPulse: Int {
        willSet {
            obj.pulse = UInt32(newValue)
        }
    }

    private func objectInit() {
        obj.idNumber = id.number
        obj.period = UInt32(usPeriod)
        obj.pulse = UInt32(usPulse)
        swiftHal_PWMOutInit(&obj)
    }

    /**
     Initialize a PWM output on a specified pin.
     - Parameter id: **REQUIRED** The name of PWMOut pin. See Id for reference.
     - Parameter frequency: **OPTIONAL** The frequency of the PWM signal.
     - Parameter dutycycle: **OPTIONAL** The duration of high output in the time period from 0.0 to 1.0.
     
     #### Usage Example
     ````
     // The most simple way of initiating a pin PWM0, with all other parameters set to default.
     let pin = PWMOut(Id.PWM0)
     ​
     // Initialize the pin PWM0 with the frequency set to 2000hz.
     let pin = PWMOut(Id.PWM0, frequency: 2000)
     
     // Initialize the pin PWM0 with the frequency set to 2000hz and the dutycycle set to 0.5.
     let pin = PWMOut(Id.PWM0, frequency: 2000, dutycycle: 0.5)
     ````
     */
    public init(_ id: IdName,
                frequency: Int = 1000,
                dutycycle: Float = 0.0) {

        self.id = id
        self.usPeriod = 1000000 / frequency
        self.usPulse = Int((1000000.0 / Float(frequency)) * dutycycle)

        obj = PWMOutObject()
        objectInit()
    }

    deinit {
        swiftHal_PWMOutDeinit(&obj)
    }

    /**
     Set the frequency and the dutycycle of a PWM output signal. The value of the dutycycle should be a float between 0.0 and 1.0.
     - Parameter frequency: The frequency of the PWM signal.
     - Parameter dutycycle: The duration of high output in the time period from 0.0 to 1.0.
     */
    @inline(__always)
    public func set(frequency: Int, dutycycle: Float) {
        guard frequency > 0 else {
            return
        }
        usPeriod = 1000000 / frequency
        usPulse = Int((1000000.0 / Float(frequency)) * dutycycle)
        swiftHal_PWMOutConfig(&obj)
    }


    /**
     Set the period and pulse width of a PWM output signal.
     - Parameter period: The period of the PWM ouput signal in microsecond.
     - Parameter pulse: The pulse width in the PWM period. This time can't be longer than the period.
     */
    @inline(__always)
    public func set(period: Int, pulse: Int) {
        usPeriod = period
        usPulse = pulse
        swiftHal_PWMOutConfig(&obj)
    }


    /**
     Set the duty cycle of a PWM output signal, that's to say, set the duration of the on-state of a signal. The value should be a float between 0.0 and 1.0.
     - Parameter dutycycle: The duration of high output in the time period from 0.0 to 1.0.
     */
    @inline(__always)
    public func setDutycycle(_ dutycycle: Float) {
        usPulse = Int(Float(usPeriod) * dutycycle)
        swiftHal_PWMOutConfig(&obj)
    }
}

