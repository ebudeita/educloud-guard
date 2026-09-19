let findings = [];

const tableBody =
    document.getElementById("findingsTableBody");

const severityFilter =
    document.getElementById("severityFilter");

const categoryFilter =
    document.getElementById("categoryFilter");

const departmentFilter =
    document.getElementById("departmentFilter");

const statusFilter =
    document.getElementById("statusFilter");

const searchFilter =
    document.getElementById("searchFilter");

const sortFilter = document.getElementById("sortFilter");

const clearFiltersButton =
    document.getElementById("clearFilters");

const previousPageButton = document.getElementById("previousPage");
const nextPageButton = document.getElementById("nextPage");
const pageInfo = document.getElementById("pageInfo");

let currentPage = 1;
const findingsPerPage = 5;

function updateSummary(data) {

    const openFindings =
        data.filter(
            finding => finding.status === "OPEN"
        );

    const resolvedFindings =
        data.filter(
            finding => finding.status === "RESOLVED"
        );


    document.getElementById("openCount").textContent =
        openFindings.length;

    document.getElementById("resolvedCount").textContent =
        resolvedFindings.length;


    document.getElementById("highCount").textContent =
        openFindings.filter(
            finding => finding.severity === "HIGH"
        ).length;

    document.getElementById("mediumCount").textContent =
        openFindings.filter(
            finding => finding.severity === "MEDIUM"
        ).length;

    document.getElementById("lowCount").textContent =
        openFindings.filter(
            finding => finding.severity === "LOW"
        ).length;


    document.getElementById("securityCount").textContent =
        openFindings.filter(
            finding => finding.category === "SECURITY"
        ).length;

    document.getElementById("governanceCount").textContent =
        openFindings.filter(
            finding => finding.category === "GOVERNANCE"
        ).length;

    document.getElementById("costCount").textContent =
        openFindings.filter(
            finding => finding.category === "COST"
        ).length;
}

function severityClass(severity) {

    return `severity-${severity.toLowerCase()}`;
}


function statusClass(status) {

    return `status-${status.toLowerCase()}`;
}


function renderFindings(data) {

    tableBody.innerHTML = "";

    if (data.length === 0) {

        tableBody.innerHTML = `
            <tr>
                <td
                    colspan="6"
                    class="empty-state"
                >
                    No findings match the selected filters.
                </td>
            </tr>
        `;

        return;
    }


    data.forEach((finding, index) => {

        const row =
            document.createElement("tr");

        if (finding.status === "RESOLVED") {
            row.classList.add("resolved-row");
        }

        row.innerHTML = `
            <td>
                ${finding.control_id}
            </td>

            <td>
                <span
                    class="
                        severity-badge
                        ${severityClass(
                            finding.severity
                        )}
                    "
                >
                    ${finding.severity}
                </span>
            </td>

            <td>
                ${finding.department}
            </td>

            <td>
                ${finding.resource_name}
            </td>

            <td>
                <span
                    class="
                        status-badge
                        ${statusClass(
                            finding.status
                        )}
                    "
                >
                    ${finding.status}
                </span>
            </td>

            <td>
                <button
                    class="details-button"
                    data-index="${index}"
                >
                    View
                </button>
            </td>
        `;

        tableBody.appendChild(row);
    });


    document
        .querySelectorAll(".details-button")
        .forEach(button => {

            button.addEventListener(
                "click",
                () => {

                    const finding =
                        data[
                            Number(
                                button.dataset.index
                            )
                        ];

                    openModal(finding);
                }
            );
        });
}

function paginateFindings(data) {
    const totalPages = Math.max(
        1,
        Math.ceil(data.length / findingsPerPage)
    );

    if (currentPage > totalPages) {
        currentPage = totalPages;
    }

    const startIndex =
        (currentPage - 1) * findingsPerPage;

    const endIndex =
        startIndex + findingsPerPage;

    const pageData =
        data.slice(startIndex, endIndex);

    pageInfo.textContent =
        `Page ${currentPage} of ${totalPages}`;

    previousPageButton.disabled =
        currentPage === 1;

    nextPageButton.disabled =
        currentPage === totalPages;

    return pageData;
}

function populateDepartments() {

    departmentFilter.innerHTML = `
        <option value="">
            All Departments
        </option>
    `;

    const departments =
        [
            ...new Set(
                findings.map(
                    finding =>
                        finding.department
                )
            )
        ].sort();


    departments.forEach(department => {

        const option =
            document.createElement("option");

        option.value = department;
        option.textContent = department;

        departmentFilter.appendChild(option);
    });
}


function applyFilters() {

    const severity =
        severityFilter.value;

    const category =
        categoryFilter.value;

    const department =
        departmentFilter.value;

    const status =
        statusFilter.value;

    const searchTerm =
        searchFilter.value
        .trim()
        .toLowerCase();

    let filtered =
        findings.filter(finding => {

            if (
                severity &&
                finding.severity !== severity
            ) {
                return false;
            }

            if (
                category &&
                finding.category !== category
            ) {
                return false;
            }

            if (
                department &&
                finding.department !== department
            ) {
                return false;
            }

            if (
                status &&
                finding.status !== status
            ) {
                return false;
            }

            if (searchTerm) {

                const searchableText = [
                    finding.control_id,
                    finding.severity,
                    finding.category,
                    finding.department,
                    finding.resource_name,
                    finding.status,
                    finding.description,
                    finding.recommendation
                ]
                    .filter(Boolean)
                    .join(" ")
                    .toLowerCase();

                if (!searchableText.includes(searchTerm)) {
                    return false;
                }
            }

            return true;
        });

                const sortBy = sortFilter.value;

                const severityRank = {
                    HIGH: 3,
                    MEDIUM: 2,
                    LOW: 1
                };

                if (sortBy === "severity") {
                    filtered.sort(
                        (a, b) =>
                            (severityRank[b.severity] || 0) -
                            (severityRank[a.severity] || 0)
                    );
                }

                if (sortBy === "department") {
                    filtered.sort((a, b) =>
                        (a.department || "").localeCompare(
                            b.department || ""
                        )
                    );
                }

                if (sortBy === "status") {
                    filtered.sort((a, b) =>
                        (a.status || "").localeCompare(
                            b.status || ""
                        )
                    );
                }

                if (sortBy === "age") {
                    filtered.sort((a, b) =>
                        new Date(a.first_detected_at || 0) -
                        new Date(b.first_detected_at || 0)
                    );
                }
    const paginatedFindings =
        paginateFindings(filtered);

    renderFindings(paginatedFindings);
}

function formatDate(value) {

    if (!value) {
        return "--";
    }

    return new Date(value).toLocaleString();
}

function calculateFindingAge(finding) {

    if (!finding.first_detected_at) {
        return "--";
    }

    const start =
        new Date(finding.first_detected_at);

    const end =
        finding.status === "RESOLVED" &&
        finding.resolved_at
            ? new Date(finding.resolved_at)
            : new Date();

    const milliseconds =
        end - start;

    if (milliseconds < 0) {
        return "--";
    }

    const days =
        Math.floor(
            milliseconds /
            (1000 * 60 * 60 * 24)
        );

    if (days === 0) {
        return "Less than 1 day";
    }

    if (days === 1) {
        return "1 day";
    }

    return `${days} days`;
}

function openModal(finding) {

    document.getElementById(
        "modalControl"
    ).textContent =
        finding.control_id;

    document.getElementById(
        "modalSeverity"
    ).textContent =
        finding.severity;

    document.getElementById(
        "modalDepartment"
    ).textContent =
        finding.department;

    document.getElementById(
        "modalResource"
    ).textContent =
        finding.resource_name;

    document.getElementById(
        "modalStatus"
    ).textContent =
        finding.status;

    document.getElementById(
        "modalFirstDetected"
    ).textContent =
        formatDate(finding.first_detected_at);

    document.getElementById(
        "modalLastDetected"
    ).textContent =
        formatDate(finding.last_detected_at);
    
    document.getElementById(
        "modalFindingAge"
    ).textContent =
        calculateFindingAge(finding);

    document.getElementById(
        "modalScanCount"
    ).textContent =
        finding.scan_count ?? 0;

    const resolvedAtRow =
        document.getElementById("resolvedAtRow");

    const resolutionCountRow =
        document.getElementById("resolutionCountRow");

    if (finding.status === "RESOLVED") {

        resolvedAtRow.style.display = "grid";
        resolutionCountRow.style.display = "grid";

        document.getElementById(
            "modalResolvedAt"
        ).textContent =
            formatDate(finding.resolved_at);

        document.getElementById(
            "modalResolutionCount"
        ).textContent =
            finding.resolution_count ?? 0;

    } else {

        resolvedAtRow.style.display = "none";
        resolutionCountRow.style.display = "none";
    }

    document.getElementById(
        "modalDescription"
    ).textContent =
        finding.description;

    document.getElementById(
        "modalRecommendation"
    ).textContent =
        finding.recommendation;


    document
        .getElementById("findingModal")
        .classList.remove("hidden");
}

function closeModal() {

    document
        .getElementById("findingModal")
        .classList.add("hidden");
}

function resetPageAndApplyFilters() {
    currentPage = 1;
    applyFilters();
}

severityFilter.addEventListener(
    "change",
    resetPageAndApplyFilters
);

categoryFilter.addEventListener(
    "change",
    resetPageAndApplyFilters
);

departmentFilter.addEventListener(
    "change",
    resetPageAndApplyFilters
);

statusFilter.addEventListener(
    "change",
    resetPageAndApplyFilters
);

searchFilter.addEventListener(
    "input",
    resetPageAndApplyFilters
);

sortFilter.addEventListener(
    "change",
    resetPageAndApplyFilters
);

clearFiltersButton.addEventListener(
    "click",
    () => {

        severityFilter.value = "";
        categoryFilter.value = "";
        departmentFilter.value = "";
        statusFilter.value = "";
        searchFilter.value = "";
        sortFilter.value = "";
        currentPage = 1;

        applyFilters();
    }
);

previousPageButton.addEventListener("click", () => {
    if (currentPage > 1) {
        currentPage--;
        applyFilters();
    }
});

nextPageButton.addEventListener("click", () => {
    currentPage++;
    applyFilters();
});

async function loadFindings() {

    try {

        const response =
            await fetch(
                "/api/findings"
            );

        if (!response.ok) {
            throw new Error(
                `HTTP ${response.status}`
            );
        }

        const data =
            await response.json();

        findings =
            data.findings || [];

        populateDepartments();

        updateSummary(findings);

        currentPage = 1;
            applyFilters();

        document.getElementById(
            "lastUpdated"
        ).textContent =
            new Date().toLocaleString();

    } catch (error) {

        console.error(
            "Unable to load findings:",
            error
        );

        tableBody.innerHTML = `
            <tr>
                <td
                    colspan="6"
                    class="empty-state"
                >
                    Unable to load live findings.
                </td>
            </tr>
        `;
    }
}

document
    .getElementById("closeModal")
    .addEventListener(
        "click",
        closeModal
    );


document
    .getElementById("findingModal")
    .addEventListener(
        "click",
        event => {

            if (
                event.target.id ===
                "findingModal"
            ) {
                closeModal();
            }
        }
    );


loadFindings();
