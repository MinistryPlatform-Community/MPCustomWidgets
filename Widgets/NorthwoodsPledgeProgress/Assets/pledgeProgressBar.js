window.addEventListener('widgetLoaded', function(event) {
    console.log('|||===> widgetLoaded Event Fired for: ' + event.detail.widgetId);       
    
    if (event.detail.widgetId == 'PledgeWidget')
    {
        console.info('Widget Rendered');
        const wrap = document.querySelector('.giving-bar');
        if (!wrap) return;

        const given     = +wrap.dataset.given || 0;
        const committed = +wrap.dataset.committed || 0;
        const goal      = +wrap.dataset.goal || 1;
        const celebration = +wrap.dataset.celebration || 0;
        const dream       = +wrap.dataset.dream || 0;

        // Clamp helpers
        const clamp = (v,min,max)=> Math.max(min, Math.min(max, v));

        // Percentages
        const pGiven      = clamp((given/goal)*100, 0, 100);
        const pCommittedT = clamp((committed/goal)*100, 0, 100);
        const pCommittedDelta = clamp(pCommittedT - pGiven, 0, 100 - pGiven);

        // Apply widths with animation trigger
        const givenEl = wrap.querySelector('.fill.given');
        const committedEl = wrap.querySelector('.fill.committed');

        // Trigger animations after a brief delay
        requestAnimationFrame(() => {
            requestAnimationFrame(() => {
                // Committed fills the full width first
                committedEl.style.left = '0%';
                committedEl.style.width = pCommittedT + '%';
                // Given overlays on top after delay
                givenEl.style.width = pGiven + '%';
                
                // Animate legend items after bars finish (1800ms for bar animations)
                const legendItems = wrap.querySelectorAll('.legend-item');
                setTimeout(() => {
                legendItems[0].classList.add('animate');
                }, 1800);
                setTimeout(() => {
                legendItems[1].classList.add('animate');
                }, 2100);
            });
        });

        // Labels
        const fmt = new Intl.NumberFormat('en-US', { style:'currency', currency:'USD', maximumFractionDigits:0 });
        wrap.querySelector('.js-given-amount').textContent = fmt.format(given);
        wrap.querySelector('.js-committed-amount').textContent = fmt.format(committed);

        // Markers: Celebration & Dream placed proportionally; God snaps to 100%
        const mkPos = v => clamp((v/goal)*100, 0, 100);
        const celeb = wrap.querySelector('.marker.celebration');
        const dreamM = wrap.querySelector('.marker.dream');
        const god   = wrap.querySelector('.marker.god');

        celeb.style.left = mkPos(celebration) + '%';
        dreamM.style.left = mkPos(dream) + '%';
        god.style.right = '0'; // already aligned to the end              

    }
});