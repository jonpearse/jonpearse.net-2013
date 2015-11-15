registerBehaviour("responsiveMedia", function()
{
	// 0. reference!
	var self = this;

	// 1. work out whether we’re an image or background
	var bImg  = (this.nodeName.toLowerCase() === 'img');

	// 2. if the URL doesn’t look like something we care about, bail
	var sStartUrl = (bImg) ? this.src : this.style.backgroundImage.replace(/url\((.*?)\)/, '$1');
	if (sStartUrl.match(/^((?:http:\/\/(?:.*?))?\/media\/(?:\d+))(?:\/([a-z])+)?$/i) === null)
		return;

	// 3. bind to resize event
	$('body').on('viewportChange', function(ev, sNewSize)
	{
		// a. get the new URL
		var sUrl = (bImg) ? self.src : self.style.backgroundImage.replace(/url\((.*?)\)/, '$1');

		// b. try to find the correct size
		var aM = sUrl.match(/^((?:http:\/\/(?:.*?))?\/media\/(?:\d+))(?:\/([a-z])+)?$/i);

		// c. if it failed, or the current size matches our new size…
		if ((aM === null) || (aM[2] === sNewSize))
			return;

		// d. change to the new size
		if (bImg)
			self.setAttribute('src', aM[1]+'/'+sNewSize);
		else
			self.style.backgroundImage = 'url('+aM[1]+'/'+sNewSize+')';
	});
});
