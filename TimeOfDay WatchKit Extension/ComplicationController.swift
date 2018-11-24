//
//  ComplicationController.swift
//  TimeOfDay WatchKit Extension
//
//  Created by Nick Rogness on 11/23/18.
//  Copyright © 2018 Rogness Software. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    override init() {
        print("ComplicationController init()")
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
        
        let calendar = Calendar.current
        let dateComponents = DateComponents(calendar: calendar,
                                            year: 1,
                                            month: 0,
                                            day: 0)
        
        let yearFromNow = calendar.date(byAdding: dateComponents, to: Date())
        
        handler(yearFromNow)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    private func createTemplate(from date:Date) -> CLKComplicationTemplate {
        let dayOfMonth = Calendar.current.component(.day, from: date)
        
        let gaugeTemplate = CLKComplicationTemplateGraphicCircularClosedGaugeText()
        gaugeTemplate.centerTextProvider = CLKSimpleTextProvider(text: "\(dayOfMonth)", shortText: "\(dayOfMonth)")
        
        let guageProvider = CLKSimpleGaugeProvider(style: .ring, gaugeColor: .white, fillFraction: 1.0)
        gaugeTemplate.gaugeProvider = guageProvider
        
        let template = CLKComplicationTemplateGraphicBezelCircularText()
        template.textProvider = CLKTimeTextProvider(date: date)
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
        
        while (entries.count < limit) {
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