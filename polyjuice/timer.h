//
//  timer.h
//  polyjuice
//
//  Created by DJ on 2018. 3. 7..
//  Copyright © 2018년 DJ. All rights reserved.
//

#ifndef timer_h
#define timer_h

#include <chrono>

class Timer {
public:
    typedef std::chrono::high_resolution_clock clock;
    typedef std::chrono::nanoseconds ns;
    Timer() { Start(); }
    /**
     * @brief Starts a timer.
     */
    inline void Start() { start_time_ = clock::now(); }
    inline float NanoSeconds() {
        return static_cast<float>(
                                  std::chrono::duration_cast<ns>(clock::now() - start_time_).count());
    }
    /**
     * @brief Returns the elapsed time in milliseconds.
     */
    inline float MilliSeconds() { return NanoSeconds() / 1000000.f; }
    /**
     * @brief Returns the elapsed time in microseconds.
     */
    inline float MicroSeconds() { return NanoSeconds() / 1000.f; }
    /**
     * @brief Returns the elapsed time in seconds.
     */
    inline float Seconds() { return NanoSeconds() / 1000000000.f; }
    
protected:
    std::chrono::time_point<clock> start_time_;
};
#endif /* timer_h */
