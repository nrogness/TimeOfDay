//
//  ComplicationController.swift
//  TimeOfDay WatchKit Extension
//
//  Created by Nick Rogness on 11/23/18.
//  Copyright © 2018 Rogness Software. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    static let minutesPerTimeline = 5
    
    override init() {
        print("ComplicationController init()")
        
        ExtensionDelegate.scheduleComplicationUpdate()
    }
    
    deinit {
        print("ComplicationController deinit()")
    }
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(Date())
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        
        let hourFromNow = Date() + TimeInterval(ComplicationController.minutesPerTimeline * 60)
        handler(hourFromNow)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    private func createTemplate(from date:Date) -> CLKComplicationTemplate {
        let dayOfMonth = Calendar.current.component(.day, from: date)
        
        
        let dayProvider = CLKSimpleTextProvider(text: "\(dayOfMonth)", shortText: "\(dayOfMonth)")
        
        var guageColor:UIColor = .white
        if let timeColorName = UserDefaults.standard.object(forKey: "TimeColor") as? String {
            if let timeColor = Colors.color(namedBy: timeColorName) {
                guageColor = timeColor
            }
        }
        
        dayProvider.tintColor = guageColor
        
        let guageProvider = CLKSimpleGaugeProvider(style: .ring, gaugeColor: guageColor, fillFraction: 1.0)
        
        let gaugeTemplate = CLKComplicationTemplateGraphicCircularClosedGaugeText()
        gaugeTemplate.centerTextProvider = dayProvider
        gaugeTemplate.gaugeProvider = guageProvider
        
        let template = CLKComplicationTemplateGraphicBezelCircularText()
        
        let textProvider = CLKTimeTextProvider(date: date)
        template.textProvider = textProvider
        
       
        template.circularTemplate = gaugeTemplate
        
        return template
    }
    
    private func createTimelineEntry(from date:Date) -> CLKComplicationTimelineEntry {
        let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: createTemplate(from: date))
        return entry
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        
        guard complication.family == .graphicBezel else { handler(nil); return }
        let currentDate = Date.init()
        let entry = createTimelineEntry(from: currentDate)
        
        handler(entry)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        
        var entries:[CLKComplicationTimelineEntry] = []
        var currentDate = date
        
        var nextMinute = currentDate.timeIntervalSince1970
        nextMinute = 60 - nextMinute.truncatingRemainder(dividingBy: 60)
        currentDate = currentDate + nextMinute + 1
        
        let realLimit = (limit > ComplicationController.minutesPerTimeline) ? ComplicationController.minutesPerTimeline : limit
        
        while (entries.count < realLimit) {
            entries.append(createTimelineEntry(from: currentDate))
            currentDate = currentDate + 60
        }
        
        handler(entries)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        guard complication.family == .graphicBezel else { handler(nil); return }
        
        let currentDate = Date.init()
        let template = createTemplate(from: currentDate)
        
        handler(template)
    }
    
}
