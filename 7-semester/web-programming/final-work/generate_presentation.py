import sys
import os
from reportlab.lib.pagesizes import letter, landscape
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, HRFlowable
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle

def build_pdf_presentation(filename="SkyTracker_Final_Project_Presentation.pdf"):
    # 16:9 aspect ratio widescreen slides (960 x 540 pt)
    slide_width = 960
    slide_height = 540

    doc = SimpleDocTemplate(
        filename,
        pagesize=(slide_width, slide_height),
        rightMargin=40,
        leftMargin=40,
        topMargin=40,
        bottomMargin=40
    )
    styles = getSampleStyleSheet()

    slide_title_style = ParagraphStyle(
        'SlideTitle',
        parent=styles['Heading1'],
        fontName='Helvetica-Bold',
        fontSize=26,
        leading=30,
        textColor=colors.HexColor('#0ea5e9'),
        spaceAfter=15
    )

    slide_body_style = ParagraphStyle(
        'SlideBody',
        parent=styles['BodyText'],
        fontName='Helvetica',
        fontSize=14,
        leading=20,
        textColor=colors.HexColor('#1e293b'),
        spaceAfter=12
    )

    bullet_style = ParagraphStyle(
        'SlideBullet',
        parent=slide_body_style,
        leftIndent=20,
        firstLineIndent=-12,
        spaceAfter=8
    )

    story = []

    # SLIDE 1: Title Slide
    story.append(Spacer(1, 40))
    story.append(Paragraph("Transport and Telecommunication Institute (TSI)", ParagraphStyle('PresUni', fontName='Helvetica-Bold', fontSize=14, leading=18, textColor=colors.HexColor('#64748b'), alignment=1)))
    story.append(Spacer(1, 20))
    story.append(Paragraph("<b>SkyTracker: Real-Time Flight Radar & Telemetry System</b>", ParagraphStyle('PresTitle', fontName='Helvetica-Bold', fontSize=32, leading=38, textColor=colors.HexColor('#0f172a'), alignment=1)))
    story.append(Spacer(1, 15))
    story.append(Paragraph("Final Project Presentation — Web Application Construction Course", ParagraphStyle('PresSub', fontName='Helvetica', fontSize=16, leading=22, textColor=colors.HexColor('#0ea5e9'), alignment=1)))
    story.append(Spacer(1, 40))
    story.append(Paragraph("<b>Author:</b> Artyom Vorontsov | <b>Tech Stack:</b> React, NestJS, PostgreSQL, SASS, OpenSky API", ParagraphStyle('PresMeta', fontName='Helvetica', fontSize=12, leading=16, textColor=colors.HexColor('#475569'), alignment=1)))
    story.append(PageBreak())

    # SLIDE 2: Project Goal & Vision
    story.append(Paragraph("1. Project Goal & Overview", slide_title_style))
    story.append(HRFlowable(width="100%", thickness=2, color=colors.HexColor('#0ea5e9'), spaceAfter=20))
    story.append(Paragraph("• <b>Objective:</b> Construct a high-performance dynamic web application to track live commercial aircraft globally.", slide_body_style))
    story.append(Paragraph("• <b>Live Telemetry Data:</b> Integrates directly with OpenSky Network REST API for real-time state vectors.", slide_body_style))
    story.append(Paragraph("• <b>Modern UI/UX:</b> Implements a responsive dark glassmorphic radar dashboard built in React & SASS.", slide_body_style))
    story.append(Paragraph("• <b>Persistence & API:</b> Powered by a NestJS REST API with PostgreSQL database caching and user watchlists.", slide_body_style))
    story.append(PageBreak())

    # SLIDE 3: Architecture & Technologies Used
    story.append(Paragraph("2. System Architecture & Tech Stack", slide_title_style))
    story.append(HRFlowable(width="100%", thickness=2, color=colors.HexColor('#0ea5e9'), spaceAfter=20))
    
    stack_data = [
        [Paragraph("<b>Layer</b>", slide_body_style), Paragraph("<b>Technologies & Libraries</b>", slide_body_style), Paragraph("<b>Key Role</b>", slide_body_style)],
        [Paragraph("Frontend", slide_body_style), Paragraph("React 18, TypeScript, Leaflet, SASS", slide_body_style), Paragraph("Interactive map UI, real-time telemetry rendering", slide_body_style)],
        [Paragraph("Backend API", slide_body_style), Paragraph("NestJS, RxJS, Axios, Swagger OpenAPI", slide_body_style), Paragraph("OpenSky ingestion, REST endpoints, telemetry stats", slide_body_style)],
        [Paragraph("Database", slide_body_style), Paragraph("PostgreSQL, TypeORM", slide_body_style), Paragraph("Persistent flight logs & user watchlists", slide_body_style)],
        [Paragraph("DevOps", slide_body_style), Paragraph("Docker, Docker Compose, Nginx", slide_body_style), Paragraph("Containerized local execution & hosting configs", slide_body_style)],
    ]
    t_stack = Table(stack_data, colWidths=[150, 330, 400])
    t_stack.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#e0f2fe')),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#cbd5e1')),
        ('PADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_stack)
    story.append(PageBreak())

    # SLIDE 4: 5 Dynamic Elements Showcase
    story.append(Paragraph("3. Demonstration of 5 Dynamic Elements", slide_title_style))
    story.append(HRFlowable(width="100%", thickness=2, color=colors.HexColor('#0ea5e9'), spaceAfter=15))
    story.append(Paragraph("1. <b>Dynamic Radar Map:</b> Real-time moving plane markers rotated live based on heading degrees.", bullet_style))
    story.append(Paragraph("2. <b>Aircraft Telemetry Inspector:</b> Live side panel inspecting speed, altitude, and vertical rate of selected planes.", bullet_style))
    story.append(Paragraph("3. <b>Airspace Statistics Aggregator:</b> Metrics card dynamically calculating average speed and airborne totals.", bullet_style))
    story.append(Paragraph("4. <b>Multi-Attribute Airspace Filter:</b> Instant callsign/country search and airborne-only filter toggle.", bullet_style))
    story.append(Paragraph("5. <b>Pinned Watchlist Manager:</b> Interactive bookmarking persisting user-tracked aircraft to PostgreSQL.", bullet_style))
    story.append(PageBreak())

    # SLIDE 5: SASS & Best Practices
    story.append(Paragraph("4. Advanced Styling & Web Best Practices", slide_title_style))
    story.append(HRFlowable(width="100%", thickness=2, color=colors.HexColor('#0ea5e9'), spaceAfter=20))
    story.append(Paragraph("• <b>SASS Preprocessor:</b> Utilized custom variables, nested selectors, and `@mixin glass-panel` for clean styling.", slide_body_style))
    story.append(Paragraph("• <b>RESTful API Standards:</b> NestJS controller endpoints following OpenAPI specifications with Swagger docs.", slide_body_style))
    story.append(Paragraph("• <b>Resilience & Fallback:</b> Graceful degradation with dynamic flight drift simulation if API rate limits occur.", slide_body_style))
    story.append(Paragraph("• <b>Production Readiness:</b> Docker Compose orchestrates database, backend, and static Nginx frontend seamlessly.", slide_body_style))
    story.append(PageBreak())

    # SLIDE 6: Summary & Q&A
    story.append(Spacer(1, 40))
    story.append(Paragraph("<b>Project Summary & Final Results</b>", slide_title_style))
    story.append(HRFlowable(width="100%", thickness=2, color=colors.HexColor('#0ea5e9'), spaceAfter=20))
    story.append(Paragraph("✔ Complete dynamic web application delivered according to TSI guidelines.", slide_body_style))
    story.append(Paragraph("✔ Source code packaged, documented, and ready for lecture presentation.", slide_body_style))
    story.append(Spacer(1, 30))
    story.append(Paragraph("<b>Thank you for your attention! Questions?</b>", ParagraphStyle('QStyle', fontName='Helvetica-Bold', fontSize=22, leading=26, textColor=colors.HexColor('#0f172a'), alignment=1)))

    doc.build(story)
    print("Presentation PDF generated successfully.")

if __name__ == '__main__':
    build_pdf_presentation()
