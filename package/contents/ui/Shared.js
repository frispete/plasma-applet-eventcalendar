.pragma library

// Qt.resolvedUrl() gives a file:// url, the scripts we run need a local path.
function urlToPath(url) {
	return decodeURIComponent(('' + url).replace(/^file:\/\//, ''))
}

function isSameDate(a, b) {
	// console.log('isSameDate', a, b)
	return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate()
}
function isDateEarlier(a, b) {
	var c = new Date(b.getFullYear(), b.getMonth(), b.getDate()) // midnight of date b
	return a < c
}
function isDateAfter(a, b) {
	var c = new Date(b.getFullYear(), b.getMonth(), b.getDate() + 1) // midnight of next day after b
	return a >= c
}
function dateTimeString(d) {
	return d.toISOString()
}
function dateString(d) {
	return d.toISOString().substr(0, 10)
}
function localeDateString(d) {
	return Qt.formatDateTime(d, 'yyyy-MM-dd')
}
function isValidDate(d) {
	if (d === null) {
		return false
	} else if (isNaN(d)) {
		return false
	} else {
		return true
	}
}

function renderText(text) {
	// console.log('renderText')
	if (typeof text === 'undefined') {
		return ''
	}
	var out = text
	// text && console.log('renderText', text)
	
	// Render links
	// Google doesn't auto-convert links to anchor tags when you paste a link in the description.
	// However, we should treat it as a link. This simple regex replacement works when we're not
	// dealing with HTML. So if we see an HTML anchor tag, skip it and assume the link has been
	// formatted.
	if (out.indexOf('<a href') === -1) {
		var rUrl = /(http|https):\/\/[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:\/~+#-]*[\w@?^=%&amp;\/~+#-])?/gi
		out = out.replace(rUrl, function(m) {
			// Google replaces ampersands with HTML the entity in the url text.
			var encodedUrl = m.replace(/\&/g, '&amp;')

			// console.log('        m', m)
			// console.log('      enc', encodedUrl)

			// Add extra space at the end to prevent styling entire text as a link when ending with a link.
			return '<a href="' + m + '">' + encodedUrl + '</a>' + '&nbsp;'
		})
	}
	// text && console.log('    Links', out)

	// Render new lines
	// out = out.replace(/\n/g, '<br>')
	// text && console.log('    Newlines', out)

	// Remove leading new line, as Google sometimes adds them.
	out = out.replace(/^(\<br\>)+/, '')
	// text && console.log('    LeadingBR', out)

	return out
}

// Merge values of objB into objA
function merge(objA, objB) {
	var keys = Object.keys(objB)
	for (var i = 0; i < keys.length; i++) {
		var key = keys[i]
		objA[key] = objB[key]
	}
}

// Remove keys from objA that are missing in objB
function removeMissingKeys(objA, objB) {
	var keys = Object.keys(objA)
	for (var i = 0; i < keys.length; i++) {
		var key = keys[i]
		if (typeof objB[key] === 'undefined') {
			delete objA[key]
		}
	}
}
