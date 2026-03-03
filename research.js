// Filter functionality
function applyFilters() {
    const year = document.getElementById('year-filter').value;
    const location = document.getElementById('location-filter').value;
    const electionType = document.getElementById('election-type-filter').value;
    const partisan = document.getElementById('partisan-filter').value;

    const reports = document.querySelectorAll('.report-card');
    let visibleCount = 0;

    reports.forEach(report => {
        const matchesYear = !year || report.dataset.year === year;
        const matchesLocation = !location || report.dataset.location === location;
        const matchesType = !electionType || report.dataset.type === electionType;
        const matchesPartisan = !partisan || report.dataset.partisan === partisan;

        if (matchesYear && matchesLocation && matchesType && matchesPartisan) {
            report.style.display = 'flex';
            visibleCount++;
        } else {
            report.style.display = 'none';
        }
    });

    // Update results count
    document.getElementById('results-count').textContent = visibleCount;

    // Show/hide no results message
    if (visibleCount === 0) {
        document.getElementById('no-results').style.display = 'block';
        document.querySelector('.reports-list').style.display = 'none';
    } else {
        document.getElementById('no-results').style.display = 'none';
        document.querySelector('.reports-list').style.display = 'grid';
    }
}

function clearFilters() {
    document.getElementById('year-filter').value = '';
    document.getElementById('location-filter').value = '';
    document.getElementById('election-type-filter').value = '';
    document.getElementById('partisan-filter').value = '';
    applyFilters();
}

// Initialize - show all reports on page load
document.addEventListener('DOMContentLoaded', function() {
    const totalReports = document.querySelectorAll('.report-card').length;
    document.getElementById('results-count').textContent = totalReports;
});
