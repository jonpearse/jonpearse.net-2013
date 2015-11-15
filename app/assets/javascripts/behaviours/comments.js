registerBehaviour('comments', function(ev)
{
	// 0. refs
	var oCommentSection = $(this);

	// 1. bind to click events
	oCommentSection.on('click', '[data-comments-action]', function()
	{
		// a. get action
		var sAction = this.getAttribute('data-comments-action').toLowerCase();

		// b. add a load UI
		addLoadUi($(this));

		// c. switch
		switch (sAction)
		{
			case 'new':
			case 'reply':
				return !handleAppendForm.apply(this, arguments);
				break;

			case 'cancel':
				return !handleCancelForm.apply(this, arguments);

			case 'load-all':
				return !handleLoadAll.apply(this, arguments);

			case 'edit':
				return !handleEdit.apply(this, arguments);

			case 'screen':
				return !handleScreen.apply(this, arguments);

			case 'delete':
				return !handleDelete.apply(this, arguments);
		}
		return true;
	});

	// 2. bind to submitting a form
	oCommentSection.on('submit', '.o-comment__form', function()
	{
		// a. get a handle
		var oForm = $(this);

		// b. request
		$.ajax({
			url: 		this.action,
			data: 		oForm.serialize(),
			method:		this.method,
			dataType:	'json',
			complete: 	function(oXhr)
			{
				// 1. if we’re ok, prepend our comment
				if (oXhr.responseJSON.status.toLowerCase() === "ok")
				{
					// a. insert comment
					var oExist = $('#comment-'+oXhr.responseJSON.comment_id);
					if (oExist.length > 0)
						oExist.replaceWith(oXhr.responseJSON.html);
					else
						insertComment(oXhr.responseJSON.html);

					// b. kill form
					oForm.find('[data-comments-action=cancel]').trigger('click', [ true ]);

					return;
				}

				// 2. it’s failed. Switch out the form with the new HTML
				oForm.replaceWith(oXhr.responseJSON.html);
			}
		});

		// c. button
		addLoadUi(oForm.find('button[type=submit]'));

		// d. lock all forms
		oForm.find(':input').prop('disabled', true);

		return false;
	});

	/**
	 * Function handlers
	 */
	function handleAppendForm()
	{
		// 1. get some hooks
		var oButton = $(this);
		var sAction = this.getAttribute('data-comments-action').toLowerCase();
		var oRef    = (sAction === 'new')
						? oCommentSection.children('.c-comments__header')
						: oButton.parents('.o-comment').eq(0).children('.o-comment__content');

		// 2. request the form
		$.getJSON(this.href, null, function(oData)
		{
			// a. append the form
			var oF = $(oData.html).insertAfter(oRef).hide().slideDown();

			// b. hide + reset buttons
			resetLoadUi(oButton);
			oButton.parent().addClass('js-hide');

			// c. hide any empty message
			oCommentSection.find('.c-comments__empty').addClass('js-hide');

			oF.scrollTo();
		});

		return true;
	}

	function handleCancelForm(ev, bForce)
	{
		bForce = bForce || false;

		// 1. get a handle on the form
		var oForm = $(this).parents('.o-comment__form').eq(0);

		// 2. if we’re not blocking
		if (!bForce &&
			(oForm.find(':input').filter(':changed').length > 0) &&
			!confirm("Your comment has not been saved. Are you sure you wish to cancel anyway?"))
			return true;

		// 3. re-show all buttons
		oForm.siblings().filter('.js-hide').removeClass('js-hide').end().children('.js-hide').removeClass('js-hide');
		oCommentSection.find('.empty').removeClass('js-hide');

		// 4. nuke the form
		oForm.remove();

		return true;
	}

	function handleLoadAll()
	{
		$.getJSON(this.href, null, function(oData)
		{
			// a. replace the comment list
			oCommentSection.find('.c-comments__list').replaceWith(oData.html);

			// b. remove ‘more’ links
			oCommentSection.find('.c-comments__prompt').remove();
		});

		return true;
	}

	function handleEdit()
	{
		// 1. hooks
		var oButton = $(this);

		// 2. request
		$.getJSON(this.href, null, function(oData)
		{
			// a. append the form
			var oF = $(oData.html).insertBefore(oButton.parent()).slideDown();;

			// b. hide the footer and comment
			oF.siblings('.o-comment__footer,.o-comment__content').addClass('js-hide');

			// b. hide + reset buttons
			resetLoadUi(oButton);
		});

		return true;
	}

	function handleScreen(ev)
	{
		var oRef = $(this);

		// 1. make request
		$.ajax({
			url:      this.href,
			method:   'POST',
			dataType: 'json',
			complete: function(oXhr)
			{
				// a. toggle class
				oRef.parents('article.o-comment').eq(0).toggleClass('is-screened', oXhr.responseJSON.screened);

				// b. button
				oRef.replaceWith(oXhr.responseJSON.html);
			}
		});

		return true;
	}

	function handleDelete()
	{
		// 1. confirm
		if (!confirm("Are you sure you really want to do this? It cannot be undone!"))
		{
			resetLoadUi($(this));
			return true;
		}
		var that = this;

		// 2. ping request
		$.ajax({
			url:	this.href,
			method:	'post',
			data:   {
				'_method': 'DELETE'
			},
			dataType: 'json',
			complete: function(oXhr)
			{
				$(that).parents('.o-comment').eq(0).parent().slideUp(function()
				{
					$(this).remove();
				});
			}
		});

		return true;
	}

	/**
	 * Utility functions
	 */
	function addLoadUi(oButton)
	{
		// 1. add class
		oButton.addClass('js-loading')

		// 2. add SVG
		oButton.prepend('<svg class="i--refresh -spin"><use xlink:href="#icon-refresh"></use></svg>');
	}

	function resetLoadUi(oButton)
	{
		// 1. remove the SVG we added earlier
		oButton.find('svg.-spin').remove();

		// 2. remove the class
		oButton.removeClass('js-loading');
	}

	function insertComment(sHtml)
	{
		// 0. hook
		var oCommentList = oCommentSection.children('.c-comments__list');

		// 1. if there’s no list, create one
		if (oCommentList.length === 0)
		{
			// a. create DOM
			oCommentList = $('<ol class="c-comments__list"/>').appendTo(oCommentSection);

			// b. remove prompt
			oCommentSection.children('.comments__empty').remove();
		}

		// 2. insert new comment
		oCommentList.prepend(sHtml);
	}
});
