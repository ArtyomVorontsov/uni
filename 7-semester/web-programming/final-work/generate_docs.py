import sys
import os
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, HRFlowable
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle

def build_pdf_report(filename="SkyTracker_Final_Project_Report.pdf"):
    doc = SimpleDocTemplate(
        filename,
        pagesize=letter,
        rightMargin=54,
        leftMargin=54,
        topMargin=54,
        bottomMargin=54
    )
    styles = getSampleStyleSheet()

    # Custom TSI Classic Styling
    title_style = ParagraphStyle(
        'TSITitle',
        parent=styles['Heading1'],
        fontName='Helvetica-Bold',
        fontSize=24,
        leading=28,
        textColor=colors.HexColor('#0f172a'),
        alignment=1, # Center
        spaceAfter=15
    )

    subtitle_style = ParagraphStyle(
        'TSISubTitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=12,
        leading=16,
        textColor=colors.HexColor('#475569'),
        alignment=1,
        spaceAfter=25
    )

    h1_style = ParagraphStyle(
        'TSIH1',
        parent=styles['Heading2'],
        fontName='Helvetica-Bold',
        fontSize=15,
        leading=19,
        textColor=colors.HexColor('#0ea5e9'),
        spaceBefore=14,
        spaceAfter=6
    )

    h2_style = ParagraphStyle(
        'TSIH2',
        parent=styles['Heading3'],
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=15,
        textColor=colors.HexColor('#1e293b'),
        spaceBefore=10,
        spaceAfter=4
    )

    body_style = ParagraphStyle(
        'TSIBody',
        parent=styles['BodyText'],
        fontName='Helvetica',
        fontSize=10,
        leading=14,
        textColor=colors.HexColor('#334155'),
        spaceAfter=8
    )

    bullet_style = ParagraphStyle(
        'TSIBullet',
        parent=body_style,
        leftIndent=15,
        firstLineIndent=-10,
        spaceAfter=4
    )

    story = []

    # Title Banner / TSI Classic Header
    story.append(Paragraph("TRANSPORT AND TELECOMMUNICATION INSTITUTE", ParagraphStyle('TSIHeader', fontName='Helvetica-Bold', fontSize=12, leading=14, alignment=1, textColor=colors.HexColor('#1e3a8a'))))
    story.append(Paragraph("Faculty of Computer Science and Telecommunication", ParagraphStyle('TSISubHeader', fontName='Helvetica', fontSize=10, leading=12, alignment=1, textColor=colors.HexColor('#64748b'))))
    story.append(Spacer(1, 20))
    story.append(HRFlowable(width="100%", thickness=2, color=colors.HexColor('#0ea5e9'), spaceAfter=20))

    story.append(Paragraph("FINAL PROJECT REPORT: SKYTRACKER", title_style))
    story.append(Paragraph("<b>Course:</b> Web Application Construction | <b>Date:</b> September 2026<br/><b>Author:</b> Artyom Vorontsov | <b>Degree Program:</b> Computer Science", subtitle_style))

    # Metadata Table
    meta_data = [
        [Paragraph("<b>Component</b>", body_style), Paragraph("<b>Specification / Technology</b>", body_style)],
        [Paragraph("Backend Framework", body_style), Paragraph("NestJS (TypeScript, Node.js)", body_style)],
        [Paragraph("Frontend Framework", body_style), Paragraph("React (TypeScript) with Leaflet Mapping", body_style)],
        [Paragraph("Database System", body_style), Paragraph("PostgreSQL with TypeORM ORM", body_style)],
        [Paragraph("Stylesheet Tech", body_style), Paragraph("SASS (.scss) with Mixins & Glassmorphic UI", body_style)],
        [Paragraph("External Open API", body_style), Paragraph("OpenSky Network Live Aircraft Telemetry REST API", body_style)],
        [Paragraph("Deployment", body_style), Paragraph("Docker, Docker Compose, Nginx Multi-stage build", body_style)],
    ]
    t = Table(meta_data, colWidths=[150, 350])
    t.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (1,0), colors.HexColor('#e0f2fe')),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#cbd5e1')),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('PADDING', (0,0), (-1,-1), 6),
    ]))
    story.append(t)
    story.append(Spacer(1, 15))

    # Section 1: Executive Summary & Project Objectives
    story.append(Paragraph("1. Executive Summary & Project Objectives", h1_style))
    story.append(Paragraph(
        "SkyTracker is a dynamic web application built to fulfill the final project requirements for the <i>Web Application Construction Course</i> at TSI. "
        "The system tracks live airborne aircraft in real-time by integrating with open aviation REST APIs (OpenSky Network), processing state vectors on a NestJS backend, "
        "and visualizing dynamic aircraft positions, flight headings, and telemetry metrics on a high-performance React frontend.",
        body_style
    ))

    # Section 2: Architecture & Implementation Details
    story.append(Paragraph("2. Technical Architecture & Implementation", h1_style))
    story.append(Paragraph(
        "The application adheres strictly to modern two-tier web architecture separation:",
        body_style
    ))
    story.append(Paragraph("• <b>Backend Tier (NestJS):</b> Implements modular controllers (`FlightController`) and services (`FlightService`) handling asynchronous HTTP data fetch from OpenSky API, data transformation, telemetry aggregation, and PostgreSQL database synchronization using TypeORM entities (`FlightEntity`, `WatchlistEntity`). OpenAPI Swagger documentation is embedded at `/api/docs`.", bullet_style))
    story.append(Paragraph("• <b>Frontend Tier (React & TypeScript):</b> Built using functional components and React hooks for real-time state management. Integrated Leaflet map rendering uses dynamic SVG aircraft markers rotated live based on heading angles.", bullet_style))
    story.append(Paragraph("• <b>Persistence (PostgreSQL):</b> Relational database storage for flight telemetry logs, user-selected aircraft watchlists, and priority alert settings.", bullet_style))

    # Section 3: Verification of 5 Dynamic Elements
    story.append(Paragraph("3. Fulfillment of Course Guidelines & Dynamic Elements", h1_style))
    story.append(Paragraph("The system features 5 distinct dynamic elements as mandated by the course specifications:", body_style))
    
    dyn_data = [
        [Paragraph("<b>Dynamic Element</b>", body_style), Paragraph("<b>Description & Implementation</b>", body_style)],
        [Paragraph("1. Dynamic Radar Map", body_style), Paragraph("Interactive Leaflet canvas rendering moving aircraft markers rotated live dynamically according to telemetry heading.", body_style)],
        [Paragraph("2. Telemetry Inspector", body_style), Paragraph("Interactive detailed side-panel inspecting live airspeed, altitude, vertical rate, and ICAO registration upon selecting any aircraft.", body_style)],
        [Paragraph("3. Airspace Aggregator", body_style), Paragraph("Live statistical dashboard computing average airspace speed, total airborne vs. grounded aircraft, and peak altitude.", body_style)],
        [Paragraph("4. Multi-Attribute Filter", body_style), Paragraph("Real-time responsive search bar and toggle filters (e.g., Airborne Only) instantly pruning the flight vector dataset.", body_style)],
        [Paragraph("5. Pinned Watchlist", body_style), Paragraph("Dynamic bookmarking feature allowing users to pin critical aircraft to a watchlist persisted via REST API to PostgreSQL.", body_style)],
    ]
    t_dyn = Table(dyn_data, colWidths=[140, 360])
    t_dyn.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (1,0), colors.HexColor('#f1f5f9')),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#cbd5e1')),
        ('PADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(t_dyn)
    story.append(Spacer(1, 10))

    # Section 4: Advanced Styling & Preprocessors
    story.append(Paragraph("4. Stylesheet Techniques & Preprocessing", h1_style))
    story.append(Paragraph(
        "Styling was crafted using **SASS (SCSS)** preprocessor features. Key design techniques include:",
        body_style
    ))
    story.append(Paragraph("• <b>Glassmorphism UI:</b> Created using `@mixin glass-panel` leveraging backdrop filters (`backdrop-filter: blur(16px)`), subtle translucent background gradients, and glowing borders.", bullet_style))
    story.append(Paragraph("• <b>Nested Scoping & Variables:</b> Organized color schemes (`$accent-color`, `$bg-dark`) ensuring dark-mode visual hierarchy.", bullet_style))

    # Section 5: Deployment & Hosting Config
    story.append(Paragraph("5. Deployment & Containerization Setup", h1_style))
    story.append(Paragraph(
        "To enable production hosting, the project includes multi-stage Docker builds and a master `docker-compose.yml` file. "
        "The frontend is compiled to static assets served via an optimized Nginx web server container, while NestJS and PostgreSQL run in isolated network bridges.",
        body_style
    ))

    # Section 6: Conclusion
    story.append(Paragraph("6. Conclusion & Results", h1_style))
    story.append(Paragraph(
        "All requirements outlined in the TSI Web Application Construction course guidelines have been fully implemented. "
        "The application demonstrates robust software architecture, clean REST API contracts, modern styling, dynamic user interactivity, and production container readiness.",
        body_style
    ))

    doc.build(story)
    print("Report PDF generated successfully.")

if __name__ == '__main__':
    build_pdf_report()
