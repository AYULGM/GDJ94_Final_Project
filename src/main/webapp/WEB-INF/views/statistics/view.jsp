<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
	<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="../includes/admin_header.jsp" />

<!-- Main content for statistics -->
<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">통계 대시보드</h3>
            </div>
            <div class="card-body">
                <p>이곳에 다양한 통계 차트와 데이터가 표시됩니다.</p>
                <!-- Example Chart -->
                <div id="some-chart" style="height: 300px;"></div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />

<!-- Page specific script for charts -->
<script src="https://cdn.jsdelivr.net/npm/apexcharts@3.37.1/dist/apexcharts.min.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    var options = {
          series: [{
          name: '방문자 수',
          data: [31, 40, 28, 51, 42, 109, 100]
        }],
          chart: {
          height: 300,
          type: 'area'
        },
        dataLabels: {
          enabled: false
        },
        stroke: {
          curve: 'smooth'
        },
        xaxis: {
          type: 'datetime',
          categories: ["2025-12-17", "2025-12-18", "2025-12-19", "2025-12-20", "2025-12-21", "2025-12-22", "2025-12-23"]
        },
        tooltip: {
          x: {
            format: 'dd/MM/yy'
          },
        },
        };

        var chart = new ApexCharts(document.querySelector("#some-chart"), options);
        chart.render();
});
</script>
