package com.kos.app.controller;

import com.kos.app.service.AnalyticsService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/analytics")
@CrossOrigin(origins = "*")
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    public AnalyticsController(AnalyticsService analyticsService) {
        this.analyticsService = analyticsService;
    }

    @GetMapping("/occupancy-trend")
    public ResponseEntity<List<Map<String, Object>>> getOccupancyTrend(
            @RequestParam(required = false) Long kostId,
            @RequestParam Integer year) {

        List<Map<String, Object>> trendData = analyticsService.getOccupancyTrend(kostId, year);
        return ResponseEntity.ok(trendData);
    }
}