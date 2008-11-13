$(document).ready(function()
{
   var pt = $('#page_title');
   var ps = $('#page_slug');
   var regex = /[\!\*'"″′‟‛„‚”“”˝\(\);:@&=+$,\/?%#\[\]]/gim;

   var pt_function = function()
   {
      if(ps.attr('donotmodify') != 'true') ps.attr('value', pt.attr('value').toLowerCase().replace(/\s/gim, '_').replace(regex, ''));
   };

   if(ps.attr('value') == '')
   {
      pt.bind("keyup", pt_function);
      pt.bind("blur", pt_function);
   }

   ps.bind("blur", function()
   {
      ps.attr('value', ps.attr('value').toLowerCase().replace(/\s/gim, '_').replace(regex, ''));
      ps.attr('donotmodify', 'true');
   });
});