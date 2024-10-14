function createBarChart(data, elementId, labelFieldName, valueFieldName, dataSetLabel)
{
    const ctx = document.getElementById(elementId);

    const labels = data.map(x => x[labelFieldName]);
    const values = data.map(x => x[valueFieldName]);

    new Chart(ctx, {
        type: 'bar',
        data: {
        labels: labels,
        datasets: [{
            label: dataSetLabel,
            data: values,
            borderWidth: 1
        }]
        },
        options: {
        scales: {
            y: {
            beginAtZero: true
            }
        }
        }
    });                 
}

function createDonutChart(data, elementId, labelFieldName, valueFieldName, dataSetLabel, showLegend = false)
{
    const ctx = document.getElementById(elementId);

    const labels = data.map(x => x[labelFieldName]);
    const values = data.map(x => x[valueFieldName]);

    new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: labels,
            datasets: [{
                label: dataSetLabel,
                data: values,
                borderWidth: 1
            }],
            hoverOffset: 4
        },
        options: {
            plugins: {
                legend: {
                    display: showLegend,
                }
            }
        }
    });                 
} 