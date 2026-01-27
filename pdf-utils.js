(function () {
  const DEFAULT_MARGIN = 40;
  let cachedLogo = null;

  // Uses your file "logo1.png" as the main logo source
  const DEFAULT_LOGO_SRC = 'logo1.png';
  // We remove the huge inline base64 fallback to keep the file small
  const DEFAULT_LOGO_DATA_URL = '';

  const toUpper = value => (value || '').toString().trim().toUpperCase();

  const formatDateLong = value => {
    if (!value) return '';
    const parsed = new Date(value);
    if (Number.isNaN(parsed.getTime())) {
      return toUpper(value);
    }
    return parsed.toLocaleDateString('en-GB', {
      day: '2-digit',
      month: 'long',
      year: 'numeric'
    });
  };

  const normaliseMetadata = (metadata = {}) => {
    const copy = { ...metadata };
    if (copy.issueDate && !copy.friendlyIssueDate) {
      copy.friendlyIssueDate = formatDateLong(copy.issueDate);
    }
    if (copy.generatedAt && !copy.generatedOn) {
      copy.generatedOn = formatDateLong(copy.generatedAt);
    }
    return copy;
  };

  const renderBanner = (doc, pageWidth) => {
    const bands = [
      { colour: [45, 45, 45], height: 20 },
      { colour: [180, 120, 60], height: 8 },
      { colour: [45, 45, 45], height: 6 }
    ];
    let offsetY = 0;
    bands.forEach(band => {
      doc.setFillColor(...band.colour);
      doc.rect(0, offsetY, pageWidth, band.height, 'F');
      offsetY += band.height;
    });
    return offsetY;
  };

  const drawLogo = (doc, logo, centreX, startY, maxHeight) => {
    if (!logo || !logo.dataUrl) return startY;

    const aspect = logo.width && logo.height ? logo.height / logo.width : 1;
    const height = Math.min(maxHeight, logo.height || maxHeight);
    const width = height / (aspect || 1);
    const imageX = centreX - width / 2;

    doc.addImage(logo.dataUrl, 'PNG', imageX, startY, width, height, 'SEGiLogo', 'FAST');
    return startY + height + 12;
  };

  const fallbackLogo = resolve => {
    // No embedded base64 now – if "logo1.png" fails, just continue without logo
    if (!DEFAULT_LOGO_DATA_URL) {
      resolve(null);
      return true;
    }
    if (cachedLogo && cachedLogo.dataUrl === DEFAULT_LOGO_DATA_URL) {
      resolve(cachedLogo);
      return true;
    }
    const fallbackImage = new Image();
    fallbackImage.onload = () => {
      cachedLogo = {
        dataUrl: DEFAULT_LOGO_DATA_URL,
        width: fallbackImage.naturalWidth || fallbackImage.width || 120,
        height: fallbackImage.naturalHeight || fallbackImage.height || 120
      };
      resolve(cachedLogo);
    };
    fallbackImage.onerror = () => resolve(null);
    fallbackImage.src = DEFAULT_LOGO_DATA_URL;
    return true;
  };

  const loadLogo = src => {
    if (cachedLogo) return Promise.resolve(cachedLogo);

    return new Promise(resolve => {
      const convertToDataUrl = image => {
        try {
          const canvas = document.createElement('canvas');
          canvas.width = image.naturalWidth || image.width;
          canvas.height = image.naturalHeight || image.height;
          const ctx = canvas.getContext('2d');
          ctx.drawImage(image, 0, 0);
          cachedLogo = {
            dataUrl: canvas.toDataURL('image/png'),
            width: canvas.width,
            height: canvas.height
          };
          resolve(cachedLogo);
        } catch (err) {
          console.warn('Unable to process logo for PDF export.', err);
          fallbackLogo(resolve);
        }
      };

      const existing = document.querySelector('.logo');
      if (existing && existing.complete && existing.naturalWidth) {
        convertToDataUrl(existing);
        return;
      }

      const image = new Image();
      image.crossOrigin = 'anonymous';
      image.onload = () => convertToDataUrl(image);
      image.onerror = () => {
        console.warn('Falling back for PDF export logo.');
        fallbackLogo(resolve);
      };

      const source = src || (existing ? existing.getAttribute('src') : DEFAULT_LOGO_SRC);
      if (source) {
        image.src = source;
      } else {
        if (!fallbackLogo(resolve)) {
          resolve(null);
        }
      }
    });
  };

  const normaliseNotes = notes => {
    if (!notes) return [];
    const raw = Array.isArray(notes) ? notes.join('\n') : String(notes);
    return raw
      .split('\n')
      .map(line => line.trim())
      .filter(Boolean);
  };

  const escapeRegExp = value => value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

  const firstValue = values => {
    for (const value of values) {
      if (value === undefined || value === null) continue;
      const trimmed = value.toString().trim();
      if (trimmed) return trimmed;
    }
    return '';
  };

  // ===== SUBJECT COLUMN (single code + name) =====
  const formatSubjectCell = row => {
    if (!row) return 'TBA';
    const subjectRaw =
      row.subject !== undefined && row.subject !== null
        ? row.subject.toString()
        : '';

    let code = firstValue([
      row.subjectCode,
      row.subject_code,
      row.courseCode,
      row.course_code,
      row.code,
      row.subjectId,
      row.courseId
    ]);

    let name = firstValue([
      row.subjectName,
      row.subject_name,
      row.courseName,
      row.course_name,
      row.name,
      row.title,
      row.description
    ]);

    if (subjectRaw) {
      const cleaned = subjectRaw.replace(/\r\n/g, '\n').trim();
      const dashSplit = cleaned.split(/\s*-\s*/);

      // Try to read "CODE - NAME" from subjectRaw
      if (!code && dashSplit.length) {
        code = dashSplit.shift();
      }
      if (!name && dashSplit.length) {
        const remainder = dashSplit.join(' - ').trim();
        if (remainder) name = remainder;
      }

      // If still no name and there are new lines, treat 1st as code & rest as name
      if (!name && cleaned.includes('\n')) {
        const parts = cleaned
          .split('\n')
          .map(part => part.trim())
          .filter(Boolean);
        if (parts.length) {
          if (!code) code = parts.shift();
          if (parts.length) {
            const combined = parts.join(' ').trim();
            if (combined) name = combined;
          }
        }
      }

      // If still missing, use first token as code, remaining as name
      if (!code && cleaned) {
        const tokens = cleaned.split(/\s+/);
        code = tokens[0] || cleaned;
        if (!name && tokens.length > 1) {
          name = tokens.slice(1).join(' ');
        }
      }

      // Remove code from the beginning of name if duplicated
      if (code && name) {
        const pattern = new RegExp(`^${escapeRegExp(code)}\\s*-?\\s*`, 'i');
        const stripped = name.replace(pattern, '').trim();
        if (stripped) name = stripped;
      }
    }

    if (!code && name) code = name;
    if (!code && !name) return 'TBA';

    const upperCode = toUpper(code || '');
    const upperName = toUpper(name || '');

    // If somehow same, show only once (this avoids "two codes")
    if (upperCode && upperName && upperCode === upperName) {
      return upperCode;
    }

    // Final format: first line = code, second line = name
    return upperName ? `${upperCode}\n${upperName}` : upperCode || upperName || 'TBA';
  };

  const deriveTeachingMode = value => {
    const upper = toUpper(value);
    if (!upper) return 'LECTURE';
    if (upper.includes('TUTORIAL')) return 'TUTORIAL';
    if (upper.includes('PRACTICAL')) return 'PRACTICAL';
    if (upper.includes('LAB')) return 'LAB';
    if (upper.includes('SEMINAR')) return 'SEMINAR';
    if (upper.includes('CROSS')) return 'CROSS TEACHING';
    if (upper.includes('LECTURE')) return 'LECTURE';
    return upper;
  };

  // ===== TABLE BODY (PROGRAMME COLUMN REMOVED) =====
  const buildTableRows = (schedule, programmeFallback) => {
    const programme = toUpper(programmeFallback || '');

    return (schedule || []).map(row => {
      const subjectCell = formatSubjectCell(row);
      const dayTime = toUpper(row && row.dayTime ? row.dayTime : 'N/A');
      const teachingMode = deriveTeachingMode(row && row.type ? row.type : '');
      const lecturer = toUpper(row && row.lecturer ? row.lecturer : 'TBA');
      let venue = row && row.venue ? toUpper(row.venue) : '';

      if (!venue) {
        const mode = row && row.mode ? row.mode.toLowerCase() : '';
        venue = mode === 'online' ? 'ONLINE' : 'TBA';
      }

      // programme not used as a separate column any more
      const _unusedProgramme = programme || toUpper(row && row.programme);

      return [subjectCell, dayTime, teachingMode, lecturer, venue];
    });
  };

  const ensureJsPdf = () => {
    if (!window.jspdf || !window.jspdf.jsPDF) {
      throw new Error('jsPDF library is not loaded.');
    }
    if (typeof window.jspdf.jsPDF === 'undefined') {
      throw new Error('jsPDF constructor is unavailable.');
    }
  };

  const createTimetablePdf = async (options = {}) => {
    ensureJsPdf();

    const {
      schedule = [],
      metadata = {},
      programmeLabel = '',
      docOptions = {},
      marginX = DEFAULT_MARGIN,
      logo = null
    } = options;

    const doc = new window.jspdf.jsPDF({ unit: 'pt', format: 'a4', ...docOptions });
    const pageWidth = doc.internal.pageSize.getWidth();
    const pageHeight = doc.internal.pageSize.getHeight();
    const centreX = pageWidth / 2;

    const meta = normaliseMetadata({ ...metadata });

    const bannerHeight = renderBanner(doc, pageWidth);
    let cursorY = bannerHeight + 18;

    const logoData = logo || (await loadLogo(meta.logoSrc));
    cursorY = drawLogo(doc, logoData, centreX, cursorY, 72);

    const headerWidth = pageWidth - marginX * 2;
    const programmeName = toUpper(meta.programmeName || programmeLabel);
    const sessionText = meta.session ? toUpper(meta.session) : '';
    const headerTitle = toUpper(meta.headerTitle || 'PROGRAMME TIMETABLE');
    const headerLines = [];

    if (programmeName) headerLines.push(programmeName);
    if (sessionText && sessionText !== programmeName) {
      headerLines.push(sessionText);
    } else if (!sessionText && headerTitle && headerTitle !== programmeName) {
      headerLines.push(headerTitle);
    }
    if (!headerLines.length) headerLines.push(headerTitle);

    const headerHeight = 26 + Math.max(0, headerLines.length - 1) * 14;

    doc.setFillColor(0, 0, 0);
    doc.rect(marginX, cursorY, headerWidth, headerHeight, 'F');
    doc.setTextColor(255, 255, 255);
    doc.setFont('times', 'bold');
    doc.setFontSize(13);

    let headerTextY = cursorY + 18;
    headerLines.forEach(line => {
      doc.text(line, centreX, headerTextY, { align: 'center' });
      headerTextY += 14;
    });

    cursorY += headerHeight + 12;
    doc.setTextColor(0, 0, 0);

    if (meta.intake) {
      const intakeHeight = 22;
      const intakeLabel = `INTAKE: ${toUpper(meta.intake)}`;

      doc.setFillColor(236, 170, 122);
      doc.rect(marginX, cursorY, headerWidth, intakeHeight, 'F');
      doc.setDrawColor(0, 0, 0);
      doc.rect(marginX, cursorY, headerWidth, intakeHeight, 'S');

      doc.setFont('times', 'bold');
      doc.setFontSize(11);
      doc.text(intakeLabel, centreX, cursorY + 15, { align: 'center' });

      cursorY += intakeHeight + 12;
    }

    const principalLines = [
      `Start of Class: ${meta.classStart ? toUpper(meta.classStart) : '-'}`,
      `End of Class: ${meta.classEnd ? toUpper(meta.classEnd) : '-'}`,
      `Final Exam: ${meta.finalExam ? toUpper(meta.finalExam) : '-'}`
    ];

    const principalHeight = 36 + principalLines.length * 14;

    doc.setDrawColor(0, 0, 0);
    doc.setLineWidth(1);
    doc.rect(marginX, cursorY, headerWidth, principalHeight, 'S');

    doc.setFont('times', 'bold');
    doc.setFontSize(11);
    doc.text('PRINCIPAL DATES:', centreX, cursorY + 18, { align: 'center' });

    doc.setFont('times', 'normal');
    doc.setFontSize(10);

    let principalY = cursorY + 34;
    principalLines.forEach(line => {
      doc.text(line, centreX, principalY, { align: 'center' });
      principalY += 14;
    });

    cursorY += principalHeight + 16;

    doc.setDrawColor(0, 0, 0);
    doc.setLineWidth(0.6);
    doc.line(marginX, cursorY - 8, pageWidth - marginX, cursorY - 8);

    // ===== TABLE HEAD (Programme removed) =====
    const tableHead = [[
      'SUBJECT CODE & NAME',
      'DAY & TIME',
      'TEACHING MODE',
      'LECTURER NAME',
      'VENUE'
    ]];

    const tableBody = buildTableRows(schedule, meta.programmeName || programmeLabel);

    doc.autoTable({
      head: tableHead,
      body: tableBody,
      startY: cursorY,
      margin: { left: marginX, right: marginX },
      theme: 'grid',
      tableLineColor: [0, 0, 0],
      tableLineWidth: 0.2,
      headStyles: {
        fillColor: [217, 217, 217],
        textColor: [0, 0, 0],
        font: 'times',
        fontSize: 8,
        fontStyle: 'bold',
        halign: 'center',
        valign: 'middle'
      },
      bodyStyles: {
        fillColor: [255, 255, 255],
        textColor: [0, 0, 0],
        font: 'times',
        fontSize: 8,
        valign: 'middle',
        cellPadding: { top: 4, right: 4, bottom: 4, left: 4 },
        lineColor: [0, 0, 0],
        lineWidth: 0.2
      },
      alternateRowStyles: { fillColor: [245, 245, 245] },
      columnStyles: {
        0: { cellWidth: 190, halign: 'left' }, // Subject
        1: { cellWidth: 105, halign: 'left' }, // Day & Time
        2: { cellWidth: 80, halign: 'left' },  // Teaching mode
        3: { cellWidth: 90, halign: 'left' },  // Lecturer
        4: { cellWidth: 40, halign: 'left' }   // Venue
      }
    });

    const notesLines = normaliseNotes(meta.notes);
    const tableResult = doc.lastAutoTable;
    let footerStartY = tableResult ? tableResult.finalY + 18 : cursorY + 18;

    if (notesLines.length) {
      doc.setFont('times', 'bold');
      doc.setFontSize(10);
      doc.text('Notes:', marginX, footerStartY);

      doc.setFont('times', 'normal');
      doc.setFontSize(9);
      let noteY = footerStartY + 14;

      notesLines.forEach(line => {
        if (noteY > pageHeight - DEFAULT_MARGIN) {
          doc.addPage();
          noteY = DEFAULT_MARGIN;
        }
        doc.text(`• ${line}`, marginX + 10, noteY);
        noteY += 12;
      });
    }

    return doc;
  };

  // Expose API
  window.SegiPdf = {
    loadLogo,
    createTimetablePdf
  };
})();
