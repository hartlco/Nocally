//
//  ContentView.swift
//  NocallyExample
//
//  Created by Martin Hartl on 13.02.21.
//

import SwiftUI
import Nocally
import NotificationCenter

extension Nocally.Notification: Identifiable {
    public var id: String {
        return identifier
    }
}

struct ContentView: View {
    let scheduler = NotificationScheduler()

    var body: some View {
        List {
            ForEach(scheduler.scheduledNotifications) { notification in
                VStack(alignment: .leading) {
                    Text(notification.identifier)
                        .font(.title)
                    Text(String(describing: scheduler.nextFireDate(for: notification)))
                        .font(.caption)
                }
            }
        }
        Button("Schedule", action: {
            scheduleNotification()
        })
        .padding()
    }

    func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(
            options: [UNAuthorizationOptions.alert,
                                              UNAuthorizationOptions.sound,
                                              UNAuthorizationOptions.badge]
        ) { granted, error in

            if let error = error {
                // Handle the error here.
            }

            guard granted else { return }

            let rep = Repeat.everyDays(1, time: .init(hour: 4, minute: 12))
            let trigger = Trigger(startDate: Date(),
                                  repeat: rep)
            let notification = Nocally.Notification(identifier: "test-1",
                                                    title: "test",
                                                    message: "message",
                                                    trigger: trigger)
            scheduler.schedule(notification: notification)

            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                print(requests)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
