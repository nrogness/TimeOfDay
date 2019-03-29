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
    
    private var configuredColor:UIColor {
        var color:UIColor = .white
        if let timeColorName = UserDefaults.standard.object(forKey: "TimeColor") as? String {
            if let timeColor = Colors.color(namedBy: timeColorName) {
                color = timeColor
            }
        }
        
        return color
    }
    
    private func createDayTextProvider(from date:Date) -> CLKSimpleTextProvider {
        let dayOfMonth = Calendar.current.component(.day, from: date)
        let dayProvider = CLKSimpleTextProvider(text: "\(dayOfMonth)", shortText: "\(dayOfMonth)")
        
        let color = self.configuredColor
        dayProvider.tintColor = color
        
        return dayProvider
    }
    
    private func createGaugeTemplate(from date:Date) -> CLKComplicationTemplateGraphicCircularClosedGaugeText {
        let dayProvider = createDayTextProvider(from: date)
        let guageProvider = CLKSimpleGaugeProvider(style: .ring, gaugeColor: self.configuredColor, fillFraction: 1.0)
        
        let gaugeTemplate = CLKComplicationTemplateGraphicCircularClosedGaugeText()
        gaugeTemplate.centerTextProvider = dayProvider
        gaugeTemplate.gaugeProvider = guageProvider
        
        return gaugeTemplate
    }
    
    private func createBezelCircularTextTemplate(from date:Date) -> CLKComplicationTemplate {
        let gaugeTemplate = createGaugeTemplate(from: date)
        
        let template = CLKComplicationTemplateGraphicBezelCircularText()
        
        let textProvider = CLKTimeTextProvider(date: date)
        template.textProvider = textProvider
        template.circularTemplate = gaugeTemplate
        
        return template
    }
    
//    private func createTimelineEntry(from date:Date) -> CLKComplicationTimelineEntry {
//        let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: createBezelCircularTextTemplate(from: date))
//        return entry
//    }
    
    private func createModularSmallTemplate(from date:Date) -> CLKComplicationTemplate {
        let provider = CLKTimeTextProvider(date: date)
        provider.tintColor = self.configuredColor

        let template = CLKComplicationTemplateModularSmallSimpleText()
        template.textProvider = provider
        return template
    }
    
    private func createModularLargeTemplate(from date:Date) -> CLKComplicationTemplate {
        let color = self.configuredColor
        let timeProvider = CLKTimeTextProvider(date: date)
        timeProvider.tintColor = color
        
        let dateProvider = CLKDateTextProvider(date: date, units: .day)
        dateProvider.tintColor = color
        
        let template = CLKComplicationTemplateModularLargeStandardBody()
        template.headerTextProvider = dateProvider
        template.body1TextProvider = timeProvider
        return template
    }
    
    private func createUtilitarianSmallTemplate(from date:Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateUtilitarianSmallRingText()
        template.textProvider = createDayTextProvider(from: date)
        template.tintColor = self.configuredColor
        template.ringStyle = .closed
        template.fillFraction = 1.0
        
        return template
    }
    
    func createUtilitarianSmallFlatTemplate(from date:Date) -> CLKComplicationTemplate {
        let provider = CLKTimeTextProvider(date: date)
        provider.tintColor = self.configuredColor
        
        let template = CLKComplicationTemplateUtilitarianSmallFlat()
        template.textProvider = provider
        return template
    }
    
    func createUtilitarianLargeTemplate(from date:Date) -> CLKComplicationTemplate {
        let provider = CLKTimeTextProvider(date: date)
        provider.tintColor = self.configuredColor
        
        let template = CLKComplicationTemplateUtilitarianLargeFlat()
        template.textProvider = provider
        return template
    }
    
    func createCircularSmallTemplate(from date:Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateCircularSmallRingText()
        template.textProvider = createDayTextProvider(from: date)
        template.tintColor = self.configuredColor
        template.ringStyle = .closed
        template.fillFraction = 1.0
        
        return template
    }
    
    func createExtaLargeTemplate(from date:Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateExtraLargeRingText()
        template.textProvider = createDayTextProvider(from: date)
        template.tintColor = self.configuredColor
        template.ringStyle = .closed
        template.fillFraction = 1.0
        
        return template
    }
    
    func createGraphicCornerTemplate(from date:Date) -> CLKComplicationTemplate {
        let timeProvider = CLKTimeTextProvider(date: date)
        timeProvider.tintColor = self.configuredColor
        
        let template = CLKComplicationTemplateGraphicCornerStackText()
        template.outerTextProvider = timeProvider
        template.innerTextProvider = createDayTextProvider(from: date)
        
        return template
    }
    
    func createGraphicRectangularTemplate(from date:Date) -> CLKComplicationTemplate {
        
        let color = self.configuredColor
        
        let dateProvider = CLKDateTextProvider(date: date, units: .day)
        dateProvider.tintColor = color
        let timeProvider = CLKTimeTextProvider(date: date)
        timeProvider.tintColor = color
        let gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: color, fillFraction: 1.0)
        
        let template = CLKComplicationTemplateGraphicRectangularTextGauge()
        template.headerTextProvider = dateProvider
        template.body1TextProvider = timeProvider
        template.gaugeProvider = gaugeProvider
        
        return template
    }
    
    func buildTemplate(for complication: CLKComplication, at date:Date) -> CLKComplicationTemplate? {
        var template:CLKComplicationTemplate? = nil
        switch complication.family {
        case .modularSmall:
            template = createModularSmallTemplate(from: date)
        case .modularLarge:
            template = createModularLargeTemplate(from: date)
        case .utilitarianSmall:
            template = createUtilitarianSmallTemplate(from: date)
        case .utilitarianSmallFlat:
            template = createUtilitarianSmallFlatTemplate(from: date)
        case .utilitarianLarge:
            template = createUtilitarianLargeTemplate(from: date)
        case .circularSmall:
            template = createCircularSmallTemplate(from: date)
        case .extraLarge:
            template = createExtaLargeTemplate(from: date)
        case .graphicCorner:
            template = createGraphicCornerTemplate(from: date)
        case .graphicBezel:
            template = createBezelCircularTextTemplate(from: date)
        case .graphicCircular:
            template = createGaugeTemplate(from: date)
        case .graphicRectangular:
            template = createGraphicRectangularTemplate(from: date)
        }
        
        return template
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        
        let currentDate = Date.init()
        guard let template = buildTemplate(for: complication, at: currentDate) else { handler(nil); return }
        
        let entry = CLKComplicationTimelineEntry(date: currentDate, complicationTemplate: template)
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
            guard let template = buildTemplate(for: complication, at: currentDate) else { continue }
            let entry = CLKComplicationTimelineEntry(date: currentDate, complicationTemplate: template)
            entries.append(entry)
            currentDate = currentDate + 60
        }
        
        handler(entries)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        let currentDate = Date.init()
        let template = buildTemplate(for: complication, at: currentDate)
        
        handler(template)
    }
    
}
